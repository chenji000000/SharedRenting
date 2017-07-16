//
//  PartnerConfig.h
//  AlipaySdkDemo
//
//  Created by ChaoGanYing on 13-5-3.
//  Copyright (c) 2013年 RenFei. All rights reserved.
//
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

#ifndef MQPDemo_PartnerConfig_h
#define MQPDemo_PartnerConfig_h

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088911967629619"
//收款支付宝账号
#define SellerID  @"2088911967629619"

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
#define MD5_KEY @""

//商户私钥，自助生成
#define PartnerPrivKey @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAJ5dlGefoRGRO+i8WZd6VYXElWKF5dLsa0uCfVGRrUVdGycDv9suL7Y77TLNWWkSEeALj1uVOKZgn+8eB9JJ3BTnJ74bysRlfaAB5MLLk/zHYUP+dnuUdm3yNjS60rqcsosKsDvM2wcyfHP22AMPWFQCBn3dgM+uBl40crpvsk8ZAgMBAAECgYBIZW9aj9cKOOKyWqh6XyqJpHzGNYADFKFYO6ceiwIzG4U2KLikclDNdkfRWZ7uMZyKV76Jl4X2SWXT4l6g+7LoAysFLEFUJwq+aM0lZngrS8X/0mBq9+1Bxgev/S+UreM2H4xmoU5dURad1aQFjTwJKwBwyN2EloLnMaMuNO4vIQJBANEHLB6qrJngMgBtZRI0WX/MlrRt2dNnLYT8EsYvXoz9FTaCYPXWrxu1SEp0iOZ4M+vUsSMoZZsF5QBuU3DiyLMCQQDB8+4BK9jVrEj+bZs3GrfSVgfKrlqXOQD2aKIEOjWY+OUo/VYbz4PpN9VelN9jCM/XxSWU99i2CiGqmQN3JrcDAkEAr32kDwMf8fiGQlGV35jP4zny9PydOp2PW+z+HiG68gew/ZisqvlY/pxOWyRHo6cbgE2Lgobx9xsVzizSJR5hfQJASxS8u+NXa0/oaeXQQkKrilcXaRSZqRS+FKVooq5N9UvUmkuHu/hXHj8o8BY9a78LhoGhDMvtLns5kSrutn9cNQJAOdgCfdbWwRKytq2JEi2R06KUsAMizH/x7tNWZ1HgKl+AbGYiT5jvo5Qm23rX+rENlaMFJzAVHg+xgfMmFNieXA=="


//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"

#endif
