//
//  LTFontAndColorMacros.h
//  listentrace
//
//  Created by luojie on 2019/7/22.
//  Copyright © 2019 listentrace. All rights reserved.
//

#ifndef LTFontAndColorMacros_h
#define LTFontAndColorMacros_h

#pragma mark - ================ 间距 ================
/// 默认间距
#define KNormalMargin 10.0f

#pragma mark - ================ 颜色 ================
#define RGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBHexAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

/// 主题色 导航栏颜色
#define CNavBgColor  [UIColor colorWithHexString:@"00AE68"]
#define CNavBgFontColor  [UIColor colorWithHexString:@"ffffff"]
#define CNavTextColor  [UIColor colorWithHexString:@"545C77"]
/// tabbar
#define CTabbarTextNormalColor  [UIColor colorWithHexString:@"C0C6DA"]
#define CTabbarTextSelectedColor  [UIColor colorWithHexString:@"3880ED"]
/// 默认页面背景色
#define CViewBgColor [UIColor colorWithHexString:@"F8F9FA"]
/// 分割线颜色
#define CLineColor [UIColor colorWithHexString:@"ededed"]
/// 次级字色
#define CFontColor1 [UIColor colorWithHexString:@"1f1f1f"]
/// 再次级字色
#define CFontColor2 [UIColor colorWithHexString:@"5c5c5c"]
//颜色
#define CClearColor [UIColor clearColor]
#define CWhiteColor [UIColor whiteColor]
#define CBlackColor [UIColor blackColor]
#define KRedColor [UIColor redColor]
#define kRandomColor    KRGBColor(arc4random_uniform(256)/255.0,arc4random_uniform(256)/255.0,arc4random_uniform(256)/255.0)        //随机色生成

#pragma mark - ================ 字体 ================
#define FFont12 [UIFont systemFontOfSize:12.0f]

#endif /* LTFontAndColorMacros_h */
