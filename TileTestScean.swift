//
//  TileTestScean.swift
//  game
//
//  Created by IshimotoKiko on 2016/04/01.
//  Copyright © 2016年 IshimotoKiko. All rights reserved.
//

import SpriteKit
class test:SKScene
{
    override func didMoveToView(view: SKView) {
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.backgroundColor = UIColor.whiteColor()
        
        for x in 0..<20
        {
            let room = SKSpriteNode(texture: nil, color: UIColor.orangeColor(), size: CGSizeMake(4 * CGFloat(CreateRandomInt.minMaxDesignation(min: 10, max: 15)), CGFloat(4 * CreateRandomInt.minMaxDesignation(min: 10, max: 15))))
            room.position = getRandomPointInCircle(2, 50)
            let flame = SKSpriteNode(texture: nil, color: UIColor.orangeColor(), size: CGSizeMake(room.size.width - 4, room.size.height - 4))
            room.addChild(flame)
            room.physicsBody = SKPhysicsBody(rectangleOfSize: room.size)
            room.physicsBody?.allowsRotation = false
            room.physicsBody?.linearDamping = 1
            room.physicsBody?.usesPreciseCollisionDetection = false
            room.physicsBody?.restitution = 1
            room.physicsBody?.friction = 1
            room.name = String(0)
            room.color = UIColor.blueColor()
            if(room.size > CGSizeMake(10 * 4.2, 10 * 4.2))
            {
                flame.color = UIColor.redColor()
                room.name = String(1)
            }
            self.addChild(room)
        }
    }
    var p:[Point] = []
    var line:[Line] = []
    var tri:[Triangle] = []
    var delaunayFlag = false
    var spaningFlag = false
    var countMax = 0;
    var count = 0;
    var t = 0.0;
    override func update(currentTime: NSTimeInterval) {
        /*count = 0;
        countMax = 0;
        for child in self.children
        {
            
            let f = child.physicsBody?.resting
            if(f != nil && f! == true && child.name != String(1))
            {
                //child.hidden = true
                //child.removeFromParent()
                child.physicsBody!.dynamic = false
                count += 1;
            }
            if( child.name != nil)
            {
                if(child.name! == String(0) || child.name! == String(1) )
                {
                    countMax += 1;
                }
            }
        }*/
        t += currentTime
        if(delaunayFlag == false && t >= 800000)
        {
            var count = 0
            
            for child in children
            {
                if(child.name == "1")//閾値より大きい部屋を選出
                {
                    var p_ = Point()
                    p_.Point = child.position
                    p_.Number = count
                    p.append(p_)//ポイントリストに格納
                    count += 1
                    print(p_.Number)
                }
            }
            print("Start")
            let d = DelaunayTriangles()
            d.DelaunayTriangulation(p)//ドロネー三角形演算開始
            line = d.draw()//ドロネー三角形表示
            tri = d.triangleSet
            for x1 in line
            {
                x1.lineWidth = 3
                self.addChild(x1)
                
            }
            delaunayFlag = true
            print(line.count)
            print("OK")
        }
        if spaningFlag == false && t >= 900000
        {
            //最小全域木の処理
            let s = spaningTree(path: line , point: p)
            var x = s.start()
            /*for x1 in line
            {
                x1.removeFromParent()
            }*/
            for n in x
            {
                //最小全域木となる木の色を緑に変更
                n.strokeColor = UIColor.greenColor()
                n.removeFromParent()
                self.addChild(n)
            }
            spaningFlag = true
            //終わり
        }
    }
    func roundm(n:Double, m:Double) -> CGFloat//単位長さに合わせる
    {
        return CGFloat(floor(((n + m - 1) / m)) * m)
    }
    func getRandomPointInCircle(ellipseX:Int,_ ellipseY:Int) -> CGPoint
        //短径x、長径yの楕円内に適当に点を作る
        //２項分布で作る
    {
        let t = 2 * M_PI * Double(360) / Double(CreateRandomInt.minMaxDesignation(min: 0, max: 360))
        
        let u = Double(360) / Double(CreateRandomInt.minMaxDesignation(min: -360, max: 360)) +
                Double(360) / Double(CreateRandomInt.minMaxDesignation(min: -360, max: 360))
        var r = 0.0
        if u > 1{
            r = 2-u
        }
        else
        {
            r = u
        }
        return CGPointMake(roundm(Double(ellipseX) * r * cos(t) , m: 4) + self.size.width / 2, roundm(Double(ellipseY) * r * sin(t) , m: 4) + self.size.height / 2)
    }
    
    var points:[CGPoint] = []
    var prevPointCount = 0
    let node = SKSpriteNode(texture: nil, color: UIColor.redColor(), size: CGSizeMake(360, 640))
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let t = touches.first
        let p = t!.locationInNode(self)
        prev = p
        points.append(p)
        if (points.count != prevPointCount)
        {
            /*let shape = SKShapeNode(circleOfRadius: 40)
            shape.fillColor = UIColor.redColor()
            shape.position = p
            self.addChild(shape)
            prevPointCount  = points.count*/
            //self.addChild(circle(center: p, radius: 40 ))
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let t = touches.first
        let p = t!.locationInNode(self)
        let vector = CGVectorMake(p.x - prev.x, p.y - prev.y)
        node.runAction(SKAction.moveBy(vector, duration: 0.1))
        prev = p
    }
    var prev = CGPointZero
}

func == (left:Point , rigth:Point) -> Bool
{
    return left.Point.x == rigth.Point.x && left.Point.y == rigth.Point.y
}
func > (left:CGSize , rigth:CGSize) -> Bool
{
    return left.width > rigth.width && left.height > rigth.height
}


func == (left:Triangle , rigth:Triangle) -> Bool//三角形の同値判定
{
    return
        left.points[0] == rigth.points[0] && left.points[1] == rigth.points[1] && left.points[2] == rigth.points[2] ||
        left.points[0] == rigth.points[1] && left.points[1] == rigth.points[2] && left.points[2] == rigth.points[0] ||
        left.points[0] == rigth.points[2] && left.points[1] == rigth.points[0] && left.points[2] == rigth.points[1] ||
            
        left.points[0] == rigth.points[2] && left.points[1] == rigth.points[1] && left.points[2] == rigth.points[0] ||
        left.points[0] == rigth.points[1] && left.points[1] == rigth.points[0] && left.points[2] == rigth.points[2] ||
        left.points[0] == rigth.points[0] && left.points[1] == rigth.points[2] && left.points[2] == rigth.points[1]
}
func | (left:Triangle , rigth:Triangle) -> Bool
{
    return (
        left.points[0] == (rigth.points[0]) || left.points[0] == (rigth.points[1]) || left.points[0] == (rigth.points[2]) ||
        left.points[1] == (rigth.points[0]) || left.points[1] == (rigth.points[1]) || left.points[1] == (rigth.points[2]) ||
        left.points[2] == (rigth.points[0]) || left.points[2] == (rigth.points[1]) || left.points[2] == (rigth.points[2])
    );
}

class Triangle
{
    var Uniqupe:Bool;
    init(point:[Point]) {
        points = point//頂点
        Uniqupe = true//存在の判定
        path = []//辺
        for x in 0..<3
        {
            let pa = Path()
            pa.moveToPoint(points[x].Point)
            pa.addLineToPoint(points[(x+1) % 3].Point)
            pa.dist = distance(points[x], P2: points[(x+1) % 3])
            pa.sPoint = points[x]
            pa.ePoint = points[(x+1) % 3]
            path.append(pa)
            
        }
    // 座標から三角形のSKShapeNodeを生成
    }
    var points:[Point]
    var path:[Path]
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class circle : SKNode
{
    init(center:Point , radius:CGFloat) {
        Center = center
        Radius = radius
        super.init()
        let circle = SKShapeNode(circleOfRadius: radius)
        self.addChild(circle)
        circle.fillColor = UIColor.redColor()
        self.position = center.Point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var Center:Point//円の中心
    var Radius:CGFloat//半径
}

class CreateRandomInt {
    // 最小値と最大値の間で乱数を作成する
    class func minMaxDesignation(min _min: Int, max _max: Int) -> Int {
        if _min < _max {
            let diff = _max - _min + 1
            let random : Int = Int(arc4random_uniform(UInt32(diff)))
            return random + _min
        }else {
            fatalError("error")
        }
    }
    
    // 最小値から指定の範囲までの乱数を作成する
    class func minRange(min _min: Int, range _range: Int) -> Int {
        let random : Int = Int(arc4random_uniform(UInt32(_range)))
        return _min + random
    }
    
    // 最大値から指定の範囲までの乱数を作成する
    class func maxRange(max _max: Int,range _range: Int) -> Int {
        let random : Int = Int(arc4random_uniform(UInt32(_range)))
        let min = _max - _range + 1
        return min + random
    }
}
struct Point
{
    var Point = CGPointZero
    var Number = 0
}
class Path : UIBezierPath//辺クラス
{
    var dist:CGFloat = 0;//長さ
    var sPoint = Point()//始点
    var ePoint = Point()//終点
    override init()
    {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class Line : SKShapeNode//辺を表示するクラス
{
    var path1: Path
    override init()
    {
        path1 = Path()
        super.init()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}