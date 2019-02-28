//
//  ASBanker.m
//
//  Created by Ross Gibson on 30/08/2013.
//  Copyright (c) 2013 Awarai Studios Limited. All rights reserved.
//

#import "ASBanker.h"

@implementation ASBanker

#pragma mark - Lifecycle

static ASBanker *sharedInstance = nil;

+ (ASBanker *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[super allocWithZone:nil] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:sharedInstance];
    });
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (void)dealloc {
	sharedInstance.productsRequest.delegate = nil;
    sharedInstance.productsRequest = nil;
	sharedInstance.delegate = nil;
	
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:sharedInstance];
}

#pragma mark - Getters

- (BOOL)canMakePurchases {
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - Public

- (void)fetchProducts:(NSArray *)productIdentifiers {
    self.productsToBuyOrRestore = [NSMutableArray arrayWithArray:productIdentifiers];
	if (productIdentifiers == nil) {
        [self failedToConnect];
    } else {
        if ([self canMakePurchases]) {
            NSSet *productIdentifiersSet = [NSSet setWithArray:productIdentifiers];
            
            sharedInstance.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiersSet];
            sharedInstance.productsRequest.delegate = self;
            [sharedInstance.productsRequest start];
        } else {
            if ([sharedInstance.delegate respondsToSelector:@selector(bankerCanNotMakePurchases)]) {
                [sharedInstance.delegate performSelector:@selector(bankerCanNotMakePurchases)];
            }
        }
    }
}

- (void)purchaseItem:(SKProduct *)product {
    if (product == nil) {
        [self noProductsFound];
    } else {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)restorePurchases {
    
    SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
    request.delegate = self;
    [request start];
    
    //[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - Private

- (void)failedToConnect {
	if ([sharedInstance.delegate respondsToSelector:@selector(bankerFailedToConnect)]) {
		[sharedInstance.delegate performSelector:@selector(bankerFailedToConnect)];
	}
}

- (void)noProductsFound {
	if ([sharedInstance.delegate respondsToSelector:@selector(bankerNoProductsFound)]) {
		[sharedInstance.delegate performSelector:@selector(bankerNoProductsFound)];
	}
}

- (void)foundProducts:(NSArray *)products {
	if ([sharedInstance.delegate respondsToSelector:@selector(bankerFoundProducts:)]) {
		[sharedInstance.delegate performSelector:@selector(bankerFoundProducts:) withObject:products];
	}
}

- (void)foundInvalidProducts:(NSArray *)products {
	if ([sharedInstance.delegate respondsToSelector:@selector(bankerFoundInvalidProducts:)]) {
		[sharedInstance.delegate performSelector:@selector(bankerFoundInvalidProducts:) withObject:products];
	}
}

- (void)provideContent:(SKPaymentTransaction *)paymentTransaction {
    if ([sharedInstance.delegate respondsToSelector:@selector(bankerProvideContent:)]) {
        [sharedInstance.delegate performSelector:@selector(bankerProvideContent:) withObject:paymentTransaction];
	}
}

#pragma mark - SKPaymentTransaction

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
    NSData *transactionReceipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    NSLog(@"%@",transactionReceipt);
    NSString *transactionReceiptString = [[NSString alloc] initWithData:transactionReceipt encoding:NSASCIIStringEncoding];
    NSLog(@"%@",transactionReceiptString);
    
    //bug is here
	[[NSUserDefaults standardUserDefaults] setValue:transactionReceiptString forKey:transaction.payment.productIdentifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction:transaction];
    [self provideContent:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    if ([sharedInstance.delegate respondsToSelector:@selector(bankerPurchaseComplete:)]) {
        [sharedInstance.delegate performSelector:@selector(bankerPurchaseComplete:) withObject:transaction];
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog( @"%@", transaction.originalTransaction.payment.productIdentifier );
    if( [self.productsToBuyOrRestore containsObject:transaction.originalTransaction.payment.productIdentifier] )
    {
        if (transaction.downloads.count) {
            NSLog(@"Downloading product");
            [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
        } else {
            NSLog(@"Product Unlocked");
            [self recordTransaction:transaction.originalTransaction];
            [self provideContent:transaction];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            if ([sharedInstance.delegate respondsToSelector:@selector(bankerPurchaseComplete:)]) {
                [sharedInstance.delegate performSelector:@selector(bankerPurchaseComplete:) withObject:transaction.originalTransaction];
            }
        }
    }
    else
        [self completeTransaction:transaction];
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
	if (transaction.error.code != SKErrorPaymentCancelled) {
		if ([sharedInstance.delegate respondsToSelector:@selector(bankerPurchaseFailed: withError:)]) {
			[sharedInstance.delegate performSelector:@selector(bankerPurchaseFailed: withError:) withObject:transaction.payment.productIdentifier withObject:[transaction.error localizedDescription]];
		}
    } else {
		if ([sharedInstance.delegate respondsToSelector:@selector(bankerPurchaseCancelledByUser:)]) {
			[sharedInstance.delegate performSelector:@selector(bankerPurchaseCancelledByUser:) withObject:transaction.payment.productIdentifier];
		}
	}
	
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - SKProductsRequest

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
	
	if (products == nil || [products count] == 0) {
		[self noProductsFound];
	} else {
		[self foundProducts:products];
	}
	
	if (response.invalidProductIdentifiers != nil && [response.invalidProductIdentifiers count] > 0) {
        [self foundInvalidProducts:response.invalidProductIdentifiers];
	}
    
    self.productsRequest = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	[self failedToConnect];
}

-(void)requestDidFinish:(SKRequest *)request
{
    if ([request isKindOfClass:[SKReceiptRefreshRequest class]]) {
        NSLog(@"Got a new receipt...");
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
    
}

#pragma mark - SKPaymentQueue

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    for (SKDownload *download in downloads) {
        switch (download.downloadState) {
            case SKDownloadStateActive:
                if ([sharedInstance.delegate respondsToSelector:@selector(bankerContentDownloading:)]) {
                    [sharedInstance.delegate performSelector:@selector(bankerContentDownloading:) withObject:download];
                }
                
                break;
            case SKDownloadStateFinished:
                // Download is complete. Content file URL is at
                // path referenced by download.contentURL. Move
                // it somewhere safe, unpack it and give the user
                // access to it
                if ([sharedInstance.delegate respondsToSelector:@selector(bankerContentDownloadComplete:)]) {
                    [sharedInstance.delegate performSelector:@selector(bankerContentDownloadComplete:) withObject:download];
                }
                
                [self completeTransaction:download.transaction];
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"Payment Queue");
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Trying To Purchase");
                break;
				
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Product Purchased");
                //bug is here
                if (transaction.downloads.count) {
                    NSLog(@"Downloading product");
                    [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
                } else {
                    NSLog(@"Product Unlocked");
                    [self completeTransaction:transaction];
                }
                break;
				
            case SKPaymentTransactionStateFailed:
                NSLog(@"Payment not finished");
                [self failedTransaction:transaction];
                break;
				
            case SKPaymentTransactionStateRestored:
                NSLog(@"Purchase restored");
                [self restoreTransaction:transaction];
                break;
				
            default:
                break;
        }
    }
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    [self paymentQueue:queue updatedTransactions:queue.transactions];

    if ([sharedInstance.delegate respondsToSelector:@selector(bankerDidRestorePurchases)]) {
		[sharedInstance.delegate performSelector:@selector(bankerDidRestorePurchases)];
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if ([sharedInstance.delegate respondsToSelector:@selector(bankerFailedRestorePurchases)]) {
		[sharedInstance.delegate performSelector:@selector(bankerFailedRestorePurchases)];
	}
}

@end
