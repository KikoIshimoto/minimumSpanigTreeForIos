//
//  supaningTree.swift
//  randamDungyon
//
//  Created by IshimotoKiko on 2016/06/24.
//  Copyright © 2016年 IshimotoKiko. All rights reserved.
//

/*
 最小全域木のアルゴリズム
 */
import SpriteKit

class spaningTree
{
    var paths:[Line]
    var points:[Point]
    init(path:[Line] , point:[Point])
    {
        //コストとノードを取得
        paths = path
        points = point
    }
    func start() -> [Line]
    {
        sort()//昇順にソート
        var union_find = UnionFind(num:points.count)//union-find木に登録
        var line:[Line] = []
        for path in paths//全部の辺を行う
        {
            if(!union_find.same(path.path1.sPoint.Number , path.path1.ePoint.Number))//同じ木に属すか？
            {
                union_find.unionSet(path.path1.sPoint.Number , path.path1.ePoint.Number)//同じ木に属させる
                line.append(path)
            }
        }
        return line
    }
    
    func sort()
    {
        //今回は辺の長さを基準にソートする
        //簡単なバブルソート
        var tmp = paths[0]
        var p = paths
        for (var i=0; i<p.count; ++i) {
            for (var j=i+1; j<p.count; ++j)
            {
                if (p[i].path1.dist > p[j].path1.dist) {
                    tmp =  p[i];
                    p[i] = p[j];
                    p[j] = tmp;
                }
            }
        }
        paths = p
    }

}
func <= (left:Line,write:Line) -> Bool
{
    return left.path1.sPoint == write.path1.sPoint || left.path1.sPoint == write.path1.ePoint
}
func >= (left:Line,write:Line) -> Bool
{
    return left.path1.ePoint == write.path1.sPoint || left.path1.ePoint == write.path1.ePoint
}

/*
 union-find木の構造体
 */
struct UnionFind {
    var par:[Int] = [];//親子関係
    var rank:[Int] = [];//世代
    init(num:Int)//初期化
    {
        print("count")
        print(num)
        for n in 0..<num
        {
            par.append(n)//全てのノードを登録
            rank.append(0)//全てのノードの世代を登録
        }
    }
    mutating func unionSet(x1:Int,_ y1:Int) -> Bool//ノードの合併
    {
        var x = find(x1);//根を探索
        var y = find(y1);//根を探索
        if (x != y) {
            if (rank[y] < rank[x]){//根のランクを比べる
                par[x] = y;//合併
            }
            else{
                par[y] = x//合併
                if(rank[x] == rank[y])//ランクが同じならば片方のランクを上げる
                {
                    rank[x] += 1
                }
            }
        }
        return x != y;
    }
    mutating func same (x:Int,_ y:Int) -> Bool{
        return find(x) == find(y);
    }
    mutating func find(x:Int) -> Int {//根を探索
        print(String(x) + " " + String(par[x]))
        if(par[x] == x)//自分が根なら探索終了
        {
            return x
        }
        else
        {
            par[x] = find(par[x])//再帰で探索する
            return par[x]
        }
    }
    mutating func size(x:Int) -> Int {
        return rank[x];
    }
};
