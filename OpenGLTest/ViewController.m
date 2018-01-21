//
//  ViewController.m
//  OpenGLTest
//
//  Created by weiyun on 2018/1/18.
//  Copyright © 2018年 孙世玉. All rights reserved.
//

#import "ViewController.h"
// 两个工具类
//#import <OpenGLES/ES3/gl.h>
//#import <OpenGLES/ES3/glext.h>

@interface ViewController ()<GLKViewDelegate>

{
    EAGLContext *context;
    // 着色器或者光照
    GLKBaseEffect *effect;
    
    // 顶点数量
    int vertexCount;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 2D图形编程接口： GDI、Skiz、OpenVG
    // 3D图形编程接口：DirectX、OpenGL/OpenGL ES(嵌入式)
    // 图形硬件：GPU芯片
    // OpenGL特点 1.跨操作系统平台运行  2.隐藏底层硬件信息  3.专用渲染接口 4.OpenGL和DirectX比较
    // OpenGL Shading Language (GLSL)：固定管线
    
    // 1. 设置配置
    [self setupConfig];

    // 2. 加载顶点数据
    [self uploadVertexArray];

    // 3.加载纹理
    [self uploadTexture];

}

- (void)setupConfig
{
    context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (context == nil) {
        NSLog(@"Failed to creat ES context");
        return;
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    // 颜色缓冲区格式
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    //view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    // 设置当前context
    [EAGLContext setCurrentContext:context];
    
    // 开启深度测试，让离得近的物体可以遮挡离得远的物体
   glEnable(GL_DEPTH_TEST);
   glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
}

// 只能通过点、线、三角形，正方形也还是由三角形拼出来的

- (void)uploadVertexArray
{
    //顶点数据，前三个是顶点坐标，后面两个是纹理坐标
    /**
           (0,1)  ----------- (1,1)
                  |         |
                  |         |
                  |         |
                  |         |
            (0,0) -----------(1,0)
     */
    GLfloat vertexData[] =
    {
        1.0f,-0.5f,0.0f,     1.0f,0.0f,
        1.0f,0.5f,0.0f,      1.0f,1.0f,
        0.0f,0.5f,0.0f,      0.0f,1.0f,
        
        1.0f,-0.5f,0.0f,     1.0f,0.0f,
        0.0f,0.5f,0.0f,      0.0f,1.0f,
        0.0f,-0.5f,0.0f,     0.0f,0.0f,
   
        
        // 并排渲染两个
//        0.0f,-0.5f,0.0f,     1.0f,0.0f,
//        0.0f,0.5f,0.0f,      1.0f,1.0f,
//        -1.0f, 0.5f,0.0f,    0.0f,1.0f,
//
//        0.0f,-0.5f,0.0f,     1.0f,0.0f,
//        -1.0f, 0.5f,0.0f,    0.0f,1.0f,
//        -1.0f,-0.5f,0.0f,    0.0f,0.0f,
//
        // 将纹理值调反，渲染结果就是倒的
//        0.0f,-0.5f,0.0f,     0.0f,1.0f,
//        0.0f,0.5f,0.0f,      0.0f,0.0f,
//        -1.0f, 0.5f,0.0f,    1.0f,0.0f,
//
//        0.0f,-0.5f,0.0f,     0.0f,1.0f,
//        -1.0f, 0.5f,0.0f,    1.0f,0.0f,
//        -1.0f,-0.5f,0.0f,    1.0f,1.0f,
        
        // 顶点坐标值对应的纹理坐标值改成相反的，这样渲染结果就是反的，两个渲染的纹理就是对称的。
        0.0f,-0.5f,0.0f,     0.0f,0.0f,
        -1.0f, 0.5f,0.0f,    1.0f,1.0f,
        -1.0f,-0.5f,0.0f,    1.0f,0.0f,

        0.0f,-0.5f,0.0f,     0.0f,0.0f,
        0.0f,0.5f,0.0f,      0.0f,1.0f,
        -1.0f, 0.5f,0.0f,    1.0f,1.0f,
 
    };
    
    // 顶点数
    vertexCount = 12;
    
    // 缓存区
    GLuint buffer;
    // 申请一个缓冲区
    glGenBuffers(1, &buffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    
    // 把顶点数据从CPU传到GPU
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    
    // 交给顶点
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    // 读取顶点数据交给GLKVertexAttribPosition
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,// 3个顶点数据
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(GLfloat) * 5,// 偏移量5
                          (GLfloat *)NULL);
    
    // 纹理
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    // 读取纹理数据，交给GLKVertexAttribTexCoord0
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          2,// 2个纹理
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(GLfloat) * 5,// 偏移量5
                          (GLfloat *)NULL + 3);
    
    
}

- (void)uploadTexture
{
    // Texture:纹理
    // 获取纹理（图片）保存路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"111" ofType:@"jpg"];
    
    // 读取纹理，纹理是倒的，要从左下角开始
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(1),GLKTextureLoaderOriginBottomLeft, nil];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:nil];
    
    // 创建着色器
    effect = [[GLKBaseEffect alloc] init];
    effect.texture2d0.enabled = GL_TRUE;
    effect.texture2d0.name = textureInfo.name;
    
}

#pragma mark - GLKViewDelegate代理方法回调

//这两个方法每帧都执行一次（循环执行），一般执行频率与屏幕刷新率相同（但也可以更改）。
//第一次循环时，先调用“glkView”再调用“update”。
//一般，将场景数据变化放在“update”中，而渲染代码则放在“glkView”中。

// 场景数据变化
- (void)update {
    //NSLog(@"upload");
}

// 渲染场景代码
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //NSLog(@"渲染");
    
    //启动着色器
    [effect prepareToDraw];
    
    // triangle 三角形
    glDrawArrays(GL_TRIANGLES, 0, vertexCount);
    //glDrawElements(GL_TRIANGLES, vertexCount, GL_UNSIGNED_INT, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
