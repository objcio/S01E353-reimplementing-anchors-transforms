import Foundation
import SwiftUI

public struct MyAnchor<Value> {
    var value: Value
    var convertToLocal: (Value, GeometryProxy) -> Value

    public struct Source {
        var size: CGSize? = nil
        var offset: (CGSize) -> CGPoint = { _ in .zero }
        var measure: (CGRect) -> Value
        var convertToLocal: (Value, GeometryProxy) -> Value
    }
}

extension MyAnchor<CGRect>.Source {
    public static func rect(_ r: CGRect) -> Self {
        Self(size: r.size, offset: { _ in
            r.origin
        }, measure: {
            $0
        }, convertToLocal: { sourceRect, proxy in
            let s = proxy.frame(in: .global)
            let o = sourceRect
            return o.offsetBy(dx: -s.origin.x, dy: -s.origin.y)
        })
    }

    public static var bounds: Self {
        Self(measure: { $0 }) { sourceRect, proxy in
            let s = proxy.frame(in: .global)
            let o = sourceRect
            return o.offsetBy(dx: -s.origin.x, dy: -s.origin.y)
        }
    }
}

extension CGRect {
    subscript(_ p: UnitPoint) -> CGPoint {
        CGPoint(x: origin.x + width*p.x, y: origin.y + height*p.y)
    }
}

extension MyAnchor<CGPoint>.Source {
    public static func unitPoint(_ p: UnitPoint) -> Self {
        Self(size: .zero, offset: { size in
            .init(x: size.width * p.x, y: size.height * p.y)
        }, measure: { $0.origin }) { sourcePoint, proxy in
            let s = proxy.frame(in: .global).origin
            let o = sourcePoint
            return o.applying(.init(translationX: -s.x, y: -s.y))
        }
    }
    public static var center: Self {
        unitPoint(.center)
    }

    public static var trailing: Self {
        unitPoint(.trailing)
    }
}

extension View {
    func myAnchorPreference<Value, Key: PreferenceKey>(key: Key.Type, value: MyAnchor<Value>.Source, transform: @escaping (MyAnchor<Value>) -> Key.Value) -> some View {
        overlay(alignment: .topLeading) {
            GeometryReader { outerProxy in
                let offset = value.offset(outerProxy.size)
                Color.clear
                    .frame(width: value.size?.width, height: value.size?.height)
                    .overlay(GeometryReader { innerProxy in
                        let frame = innerProxy.frame(in: .global)
                        let anchorValue = value.measure(frame)
                        let anchor = MyAnchor(value: anchorValue, convertToLocal: value.convertToLocal)
                        Color.clear.preference(key: key, value: transform(anchor))
                    })
                    .offset(x: offset.x, y: offset.y)
            }
        }
    }
}

extension GeometryProxy {
    subscript<Value>(_ anchor: MyAnchor<Value>) -> Value {
        anchor.convertToLocal(anchor.value, self)
    }
}
