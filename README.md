# LJJCycleScrollView
简介

1、实现循环滚动的scroolView，scrollView只包涵三个子控件，展示的是有中间一个，其他的用来做动画

2、因为一开始写的时候加载的相册图片，每一张图片都很大，多张之后内存暴涨，所以引入图片等比缩放和有损压缩，有效的减少内存占用。对于图片宽小于屏幕宽 且图片高小于屏幕高的，不进行缩放和压缩

3、这个使用起来也特别方便，可以使用XIB、storyBoard引用，也可以使用代码创建

4、该类加载网络图片和缩放图片的时候都没有进行图片缓存，所以如果需要完美的话需要自己去实现


版本记录

0.0.1

基本实现，基础功能基本满足


0.0.2

1、增加一个代理方法，使循环滚动展示的imageView能够在外部加载。因此展示的imageView可以更加灵活的加载。（你可以实现代理，使用三方库进行加载，比如SD、YYKit、AF等，不必再去修改源代码）。

2、增加placeholderImage（占位图）

3、增加设置当前展示的下标

4、增加注释，便于理解
