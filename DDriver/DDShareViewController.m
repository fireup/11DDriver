//
//  DDShareViewController.m
//  DDriver
//
//  Created by ZBN on 14-8-4.
//  Copyright (c) 2014年 fireup. All rights reserved.
//

//typedef enum WXScene {
//    
//    WXSceneSession  = 0,        /**< 聊天界面    */
//    WXSceneTimeline = 1,        /**< 朋友圈      */
//    WXSceneFavorite = 2,        /**< 收藏       */
//} WXShareScene;



#import "DDShareViewController.h"
#import "WXApi.h"
#import "WXApiObject.h"

typedef enum WXScene WXShareScene;

@interface DDShareViewController ()

@end

@implementation DDShareViewController

- (IBAction)shareToWXMsg:(UIButton *)sender
{
//    [self.navigationController popToRootViewControllerAnimated:YES];
    [self shareToWXWithScene:WXSceneSession];
}

- (IBAction)shareToWXTimeline:(UIButton *)sender
{
    
    [self shareToWXWithScene:WXSceneTimeline];
}

- (void)shareToWXWithScene:(WXShareScene)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"11代驾：安全快捷";
    message.description = @"我刚刚用11代驾预约了代驾司机，现在已经安全到家了！";
    [message setThumbImage:[UIImage imageNamed:@"logo"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = @"http://www.11daijia.com";
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        
        NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



@end
