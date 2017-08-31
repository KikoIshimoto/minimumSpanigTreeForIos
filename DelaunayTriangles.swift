//
//  DelaunayTriangles.swift
//  randamDungyon
//
//  Created by IshimotoKiko on 2016/06/15.
//  Copyright © 2016年 IshimotoKiko. All rights reserved.
//

import SpriteKit

class DelaunayTriangles {
    var triangleSet:[Triangle] = []  // 三角形リスト
    
    init() {
    }
    
    // ======================================
    // 点のリストを与えて、Delaunay三角分割を行う
    // ======================================
    func DelaunayTriangulation(pointList:[Point])
    {
        
        triangleSet = []
        // 巨大な外部三角形をリストに追加
        let hugeTriangle = getHugeTriangle();
        triangleSet.append(hugeTriangle);
        
        // --------------------------------------
        // 点を逐次添加し、反復的に三角分割を行う
        // --------------------------------------
        var cou = 0;
        for point in 0 ..< pointList.count
        {
            // --------------------------------------
            // 追加候補の三角形を保持する一時ハッシュ
            // --------------------------------------
            var tmpTriangleSet:[Triangle] = [];
            // --------------------------------------
            // 現在の三角形リストから要素を一つずつ取り出して、
            // 与えられた点が各々の三角形の外接円の中に含まれるかどうか判定
            // --------------------------------------
            var max = self.triangleSet.count;
            cou = 0
            while(cou < max)
            {
                // 三角形リストから三角形を取り出して…
                // その外接円を求める。
                let tri = self.triangleSet[cou]
                let cir = self.getCircumscribedCirclesOfTriangle(tri)
                // --------------------------------------
                // 追加された点が外接円内部に存在する場合、
                // その外接円を持つ三角形をリストから除外し、
                // 新たに分割し直す
                // --------------------------------------
                if (distance(cir.Center, P2:pointList[point]) <= cir.Radius) {
                    // 新しい三角形を作り、一時ハッシュに入れる
                    addElementToRedundanciesMap(&tmpTriangleSet , t:Triangle(point:[pointList[point], tri.points[0], tri.points[1]]))
                    addElementToRedundanciesMap(&tmpTriangleSet , t:Triangle(point:[pointList[point], tri.points[1], tri.points[2]]))
                    addElementToRedundanciesMap(&tmpTriangleSet , t:Triangle(point:[pointList[point], tri.points[2], tri.points[0]]))
                    // 旧い三角形をリストから削除
                    self.triangleSet.removeAtIndex(cou)
                    max = self.triangleSet.count
                }
                else{
                    cou += 1;
                }
            }
            // --------------------------------------
            // 一時ハッシュのうち、重複のないものを三角形リストに追加
            // --------------------------------------
            //ここ治す
            for tri in tmpTriangleSet
            {
                if tri.Uniqupe
                {
                    self.triangleSet.append(tri)
                }
            }
        }
        
        // 最後に、外部三角形の頂点を削除
        cou = 0
        var max = self.triangleSet.count;
        while(cou < max)
        {
            // もし外部三角形の頂点を含む三角形があったら、それを削除
            if(self.triangleSet[cou] | hugeTriangle ) {
                self.triangleSet.removeAtIndex(cou)
            }
            else{
                cou += 1
            }
            max = self.triangleSet.count;
        }
    }

    // ======================================
    // 描画
    // ======================================
    func draw() -> [Line]{
        var Lines:[Line] = []
        for tri in self.triangleSet {
            for path in tri.path
            {
                let node = Line()
                node.path = path.CGPath
                node.strokeColor = UIColor.blueColor()
                node.name = "delaunayLine"
                node.path1.dist = path.dist
                node.path1.ePoint = path.ePoint
                node.path1.sPoint = path.sPoint
                var  f = false
                for line in Lines
                {
                    if(node <= line && node >= line)
                    {
                        f = true
                    }
                    if(distance(node.path1.sPoint, P2: node.path1.ePoint) > 300)
                    {
                        f = true
                    }
                }
                if f == false
                {
                    print(String(path.ePoint.Number) + " " + String(path.sPoint.Number))
                    Lines.append(node)
                }
            }
        }
        return Lines
    }


    
    // ======================================
    // 一時ハッシュを使って重複判定
    // ======================================
    func addElementToRedundanciesMap(inout HashMap:[Triangle], t:Triangle)
    {
        
        for c in 0..<HashMap.count
        {
            if HashMap[c] == t
            {
                //重複する三角形の存在を消す
                t.Uniqupe = false
                HashMap[c].Uniqupe = false
            }
        }
        if t.Uniqupe == true
        {
            HashMap.append(t)//分割した三角形を追加
        }
    }
    
    // ======================================
    // 最初に必要な巨大三角形を求める
    // ======================================
    // 画面全体を包含する正三角形を求める
    func getHugeTriangle() -> Triangle{
        return getHugeTriangle(CGPointMake(0, 0),
                               end: CGPointMake(360 * 10, 640 * 10));
    }
    // 任意の矩形を包含する正三角形を求める
    // 引数には矩形の左上座標および右下座標を与える
    func getHugeTriangle(start:CGPoint, end:CGPoint) -> Triangle {
    // start: 矩形の左上座標、
    // end  : 矩形の右下座標…になるように
        var start_ = start
        var end_ = end
        if(end.x < start.x) {
            let tmp = start.x;
            start_.x = end.x;
            end_.x = tmp;
        }
        if(end.y < start.y) {
            let tmp = start.y;
            start_.y = end.y;
            end_.y = tmp;
        }
    
    // 1) 与えられた矩形を包含する円を求める
    //      円の中心 c = 矩形の中心
    //      円の半径 r = |p - c| + ρ
    //    ただし、pは与えられた矩形の任意の頂点
    //    ρは任意の正数
        let center = CGPointMake( (end.x - start.x) / 2.0,
                                  (end.y - start.y) / 2.0 );
        var Cen = Point()
        Cen.Point = center
        var Sta = Point()
        Sta.Point = start
        
        let radius = distance(Cen, P2: Sta) + 1.0;
    
    // 2) その円に外接する正三角形を求める
    //    重心は、円の中心に等しい
    //    一辺の長さは 2√3･r
        let x1 = center.x - sqrt(3) * radius;
        let y1 = center.y - radius;
        var p1 = Point()
        p1.Point = CGPointMake(x1, y1);
    
        let x2 = center.x + sqrt(3) * radius;
        let y2 = center.y - radius;
        var p2 = Point()
        p2.Point = CGPointMake(x2, y2);
    
        let x3 = center.x;
        let y3 = center.y + 2 * radius;
        var p3 = Point()
        p3.Point = CGPointMake(x3, y3);
        
        return Triangle(point: [p1, p2, p3]);
    }
    
    // ======================================
    // 三角形を与えてその外接円を求める
    // ======================================
    func getCircumscribedCirclesOfTriangle(t:Triangle) -> circle {
    // 三角形の各頂点座標を (x1, y1), (x2, y2), (x3, y3) とし、
    // その外接円の中心座標を (x, y) とすると、
    //     (x - x1) * (x - x1) + (y - y1) * (y - y1)
    //   = (x - x2) * (x - x2) + (y - y2) * (y - y2)
    //   = (x - x3) * (x - x3) + (y - y3) * (y - y3)
    // より、以下の式が成り立つ
    //
    // x = { (y3 - y1) * (x2 * x2 - x1 * x1 + y2 * y2 - y1 * y1)
    //     + (y1 - y2) * (x3 * x3 - x1 * x1 + y3 * y3 - y1 * y1)} / c
    //
    // y = { (x1 - x3) * (x2 * x2 - x1 * x1 + y2 * y2 - y1 * y1)
    //     + (x2 - x1) * (x3 * x3 - x1 * x1 + y3 * y3 - y1 * y1)} / c
    //
    // ただし、
    //   c = 2 * {(x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1)}
    
        let x1 = t.points[0].Point.x;
        let y1 = t.points[0].Point.y;
        let x2 = t.points[1].Point.x;
        let y2 = t.points[1].Point.y;
        let x3 = t.points[2].Point.x;
        let y3 = t.points[2].Point.y;
    
        let c = 2.0 * ((x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1));
        let x = ((y3 - y1) * (x2 * x2 - x1 * x1 + y2 * y2 - y1 * y1) + (y1 - y2) * (x3 * x3 - x1 * x1 + y3 * y3 - y1 * y1))/c;
        let y = ((x1 - x3) * (x2 * x2 - x1 * x1 + y2 * y2 - y1 * y1) + (x2 - x1) * (x3 * x3 - x1 * x1 + y3 * y3 - y1 * y1))/c;
        var center = Point()
        center.Point = CGPointMake(x, y);
        
    // 外接円の半径 r は、半径から三角形の任意の頂点までの距離に等しい
        let r = distance(center, P2: t.points[1])
    
        return circle(center: center, radius: r);
    }
}
func distance(P1:Point,P2:Point)->CGFloat
{
     return pow( (P1.Point.x - P2.Point.x) * (P1.Point.x - P2.Point.x) + (P1.Point.y - P2.Point.y) * (P1.Point.y - P2.Point.y), 0.5 );
}













