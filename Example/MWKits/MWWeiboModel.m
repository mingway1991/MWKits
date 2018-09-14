//
//  MWWeiboModel.m
//  ModelBenchmark
//
//  Created by 石茗伟 on 2018/9/13.
//  Copyright © 2018年 ibireme. All rights reserved.
//

#import "MWWeiboModel.h"

@implementation MWWeiboPictureMetadata
MWCodingImplementation
- (NSDictionary<NSString *, NSString *> *)mw_redirectMapper {
    return @{@"cut_type":@"cutType"};
}

@end

@implementation MWWeiboPicture
MWCodingImplementation
- (NSDictionary<NSString *, NSString *> *)mw_redirectMapper {
    return @{@"pic_id":@"picID",
             @"keep_size":@"keepSize",
             @"photo_tag":@"photoTag",
             @"object_id":@"objectID",
             @"middleplus":@"middlePlus"};
}

@end

@implementation MWWeiboURL
MWCodingImplementation
- (NSDictionary<NSString *, NSString *> *)mw_redirectMapper {
    return @{@"ori_url":@"oriURL",
             @"url_title":@"urlTitle",
             @"url_type_pic":@"urlTypePic",
             @"url_type":@"urlType",
             @"short_url":@"shortURL",
             @"actionlog":@"actionLog",
             @"page_id":@"pageID",
             @"storage_type":@"storageType"};
}

@end

@implementation MWWeiboUser
MWCodingImplementation
- (NSDictionary<NSString *, NSString *> *)mw_redirectMapper {
    return @{@"id":@"userID",
             @"idstr":@"idString",
             @"gender":@"genderString",
             @"bi_followers_count":@"biFollowersCount",
             @"profile_image_url":@"profileImageURL",
             @"class":@"uclass",
             @"verified_contact_email":@"verifiedContactEmail",
             @"statuses_count":@"statusesCount",
             @"geo_enabled":@"geoEnabled",
             @"follow_me":@"followMe",
             @"cover_image_phone":@"coverImagePhone",
             @"description":@"desc",
             @"followers_count":@"followersCount",
             @"verified_contact_mobile":@"verifiedContactMobile",
             @"avatar_large":@"avatarLarge",
             @"verified_trade":@"verifiedTrade",
             @"profile_url":@"profileURL",
             @"cover_image":@"coverImage",
             @"online_status":@"onlineStatus",
             @"badge_top":@"badgeTop",
             @"verified_contact_name":@"verifiedContactName",
             @"screen_name":@"screenName",
             @"verified_source_url":@"verifiedSourceURL",
             @"pagefriends_count":@"pagefriendsCount",
             @"verified_reason":@"verifiedReason",
             @"friends_count":@"friendsCount",
             @"block_app":@"blockApp",
             @"has_ability_tag":@"hasAbilityTag",
             @"avatar_hd":@"avatarHD",
             @"credit_score":@"creditScore",
             @"created_at":@"createdAt",
             @"block_word":@"blockWord",
             @"allow_all_act_msg":@"allowAllActMsg",
             @"verified_state":@"verifiedState",
             @"verified_reason_modified":@"verifiedReasonModified",
             @"allow_all_comment":@"allowAllComment",
             @"verified_level":@"verifiedLevel",
             @"verified_reason_url":@"verifiedReasonURL",
             @"favourites_count":@"favouritesCount",
             @"verified_type":@"verifiedType",
             @"verified_source":@"verifiedSource",
             @"user_ability":@"userAbility"};
}

//- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
//    if ([property.name isEqualToString:@"createdAt"]) {
//        return [[DateFormatter weiboDataFormatter] dateFromString:oldValue];
//    }
//    return oldValue;
//}

@end

@implementation MWWeiboStatus
MWCodingImplementation
- (NSDictionary<NSString *, NSString *> *)mw_redirectMapper {
    return @{@"id":@"statusID",
             @"created_at":@"createdAt",
             @"attitudes_status":@"attitudesStatus",
             @"in_reply_to_screen_name":@"inReplyToScreenName",
             @"source_type":@"sourceType",
             @"comments_count":@"commentsCount",
             @"url_struct":@"urlStruct",
             @"recom_state":@"recomState",
             @"source_allowclick":@"sourceAllowClick",
             @"biz_feature":@"bizFeature",
             @"mblogtypename":@"mblogTypeName",
             @"mblogtype":@"mblogType",
             @"in_reply_to_status_id":@"inReplyToStatusId",
             @"pic_ids":@"picIds",
             @"reposts_count":@"repostsCount",
             @"attitudes_count":@"attitudesCount",
             @"darwin_tags":@"darwinTags",
             @"userType":@"userType",
             @"pic_infos":@"picInfos",
             @"in_reply_to_user_id":@"inReplyToUserId"};
}

- (NSDictionary<NSString *, Class> *)mw_modelContainerPropertyGenericClass {
    return @{@"urlStruct" : [MWWeiboURL class],
             @"picInfos" : [MWWeiboPicture class]};
}

//- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
//    if ([property.name isEqualToString:@"createdAt"]) {
//        if ([oldValue isKindOfClass:[NSString class]]) {
//            return [[DateFormatter weiboDataFormatter] dateFromString:oldValue];
//        }
//        return nil;
//    } else if ([property.name isEqualToString:@"picInfos"]) {
//        if (!oldValue || oldValue == [NSNull null]) return nil;
//        if (![oldValue isKindOfClass:[NSDictionary class]]) return nil;
//        NSMutableDictionary *pics = [NSMutableDictionary new];
//        [((NSDictionary *)oldValue) enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *obj, BOOL *stop) {
//            if ([obj isKindOfClass:[NSDictionary class]]) {
//                MJWeiboPicture *pic = [MJWeiboPicture mj_objectWithKeyValues:obj];
//                if (pic) pics[key] = pic;
//            }
//        }];
//        return pics;
//    }
//    return oldValue;
//}

@end
