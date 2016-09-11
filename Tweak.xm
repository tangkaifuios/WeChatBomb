


static const char kf_BaseMsgContentViewControllerBombViewKey = '\0'; // 点击轰炸时候弹出来的View
static const char kf_BaseMsgContentViewControllerMessageTextFeildKey= '\0'; // 用来填写需要发送内容的UITextField
static const char kf_BaseMsgContentViewControllerCountTextFeildKey= '\0'; // 用来填写需要发送次数的UITextField
static const char kf_BaseMsgContentViewControllerTimeIntervalTextFeildKey= '\0'; // 用来填写需要发送时间间隔的UITextField
static const char kf_BaseMsgContentViewControllerCurrentCountKey= '\0'; // 已经发送了多少次啦
static const char kf_BaseMsgContentViewControllerBomdItemKey= '\0'; // 轰炸按钮
static const char kf_BaseMsgContentViewControllerStartButtonKey = '\0';  // 开始按钮
static const char kf_BaseMsgContentViewControllerTimernKey = '\0';  // 开始按钮

@interface MMInputToolView: UIView
- (void)TextViewDidEnter:(NSString *)text;
@end

@interface BaseMsgContentViewController: UIViewController
- (void)sendMessageWithMessage:(NSString *)message maxcount:(NSInteger)count;
- (void)hiddenBombMessageViewWithSender:(UIButton *)button;

- (UIView *)kf_bombView;
- (UITextField *)kf_meesageTextFeild;
- (UITextField *)kf_countTextFeild;
- (UITextField *)kf_timeIntervalTextFeild;
- (UIBarButtonItem *)kf_bomdItem;
- (UIButton *)kf_startButton;
- (NSNumber *)kf_currentTimes;
- (void)kf_setCurrentCount:(NSNumber *)number;

@end




%hook BaseMsgContentViewController
- (void)viewWillAppear:(BOOL)animated{
    %orig;
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
    UIBarButtonItem *bombItem = [self kf_bomdItem];
    if(![items containsObject:bombItem]){
        [items addObject:bombItem];
        self.navigationItem.rightBarButtonItems = items;
    }
}

%new

%new
- (void)addBombMessageView{
    [self.view addSubview:[self kf_bombView]];
    [self kf_bombView].alpha = 1.0;
    [self kf_meesageTextFeild].text = nil;
    [self kf_countTextFeild].text = nil;
    [self kf_timeIntervalTextFeild].text = nil;
}

%new
- (void)hiddenBombMessageViewWithSender:(UIButton *)button{
    if(button != nil ){
        [self.view endEditing:YES];
        [self kf_setCurrentCount: @(0)];
        NSInteger interval = [[self kf_timeIntervalTextFeild].text integerValue];
        if([[self kf_countTextFeild].text integerValue] > 0){
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateMessage) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer  forMode:NSDefaultRunLoopMode];
        objc_setAssociatedObject(self, &kf_BaseMsgContentViewControllerTimernKey, timer, OBJC_ASSOCIATION_RETAIN);
        [[self kf_meesageTextFeild] becomeFirstResponder];
    }
    }
     [self kf_bombView].alpha = 0.0;
     [self.view endEditing:YES];
}
%new
- (void)updateMessage{
    if([[self kf_countTextFeild].text integerValue] > 0){
        NSInteger maxCount = [[self kf_countTextFeild].text integerValue];
        [self sendMessageWithMessage:[self kf_meesageTextFeild].text maxcount:maxCount];
    }
}

%new
- (void)sendMessageWithMessage:(NSString *)message maxcount:(NSInteger)count{

    NSNumber *number = [self kf_currentTimes];
    NSInteger current = [number integerValue];
    if(current < count){
        MMInputToolView *toolView = (MMInputToolView *)[self valueForKey:@"_inputToolView"];
        [toolView TextViewDidEnter:message];
    }else{
       NSTimer *timer = (NSTimer *)objc_getAssociatedObject(self, &kf_BaseMsgContentViewControllerTimernKey);
        [timer invalidate];
        timer = nil;
    }
    current++;
     [self kf_setCurrentCount:@(current)];

}


// 界面相关
%new

- (UIView *)kf_bombView{
    UIView *bombView = objc_getAssociatedObject(self, &kf_BaseMsgContentViewControllerBombViewKey);
    if(bombView == nil){
        CGFloat X =  ([UIScreen mainScreen].bounds.size.width - 300) / 2;
        bombView = [[UIView alloc] initWithFrame:CGRectMake(X, 80, 300, 220)];
        objc_setAssociatedObject(self, &kf_BaseMsgContentViewControllerBombViewKey, bombView, OBJC_ASSOCIATION_RETAIN);
        bombView.layer.cornerRadius = 10;
        bombView.backgroundColor = [UIColor whiteColor];
        [bombView addSubview:[self kf_meesageTextFeild]];
        [bombView addSubview:[self kf_countTextFeild]];
        [bombView addSubview:[self kf_timeIntervalTextFeild]];
        [bombView addSubview:[self kf_startButton]];
    }
    return bombView;

}
%new

- (UITextField *)kf_meesageTextFeild{
    UITextField *messageTextFeild = objc_getAssociatedObject(self, &kf_BaseMsgContentViewControllerMessageTextFeildKey);
    if(messageTextFeild == nil){
        messageTextFeild = [[UITextField alloc] initWithFrame:CGRectMake(15, 20, 270, 30)];
        messageTextFeild.font = [UIFont systemFontOfSize:13];
        messageTextFeild.borderStyle = UITextBorderStyleRoundedRect;
        messageTextFeild.placeholder = @"发送内容";
        objc_setAssociatedObject(self, &kf_BaseMsgContentViewControllerMessageTextFeildKey, messageTextFeild, OBJC_ASSOCIATION_RETAIN);
    }
    return messageTextFeild;
}
%new

- (UITextField *)kf_countTextFeild{
    UITextField *countTextFeild = objc_getAssociatedObject(self, &kf_BaseMsgContentViewControllerCountTextFeildKey);
    if(countTextFeild == nil){
        countTextFeild = [[UITextField alloc] initWithFrame:CGRectMake(15, 70, 270, 30)];
        countTextFeild.font = [UIFont systemFontOfSize:13];
        countTextFeild.borderStyle = UITextBorderStyleRoundedRect;
        countTextFeild.placeholder = @"轰炸次数";
        countTextFeild.keyboardType = UIKeyboardTypeNumberPad;

        objc_setAssociatedObject(self, &kf_BaseMsgContentViewControllerCountTextFeildKey, countTextFeild, OBJC_ASSOCIATION_RETAIN);
    }
    return countTextFeild;
}
%new

- (UITextField *)kf_timeIntervalTextFeild{
    UITextField *timeIntervalTextFeild = objc_getAssociatedObject(self, &kf_BaseMsgContentViewControllerTimeIntervalTextFeildKey);
    if(timeIntervalTextFeild == nil){
        timeIntervalTextFeild = [[UITextField alloc] initWithFrame:CGRectMake(15, 120, 270, 30)];
        timeIntervalTextFeild.font = [UIFont systemFontOfSize:13];
        timeIntervalTextFeild.borderStyle = UITextBorderStyleRoundedRect;
        timeIntervalTextFeild.placeholder = @"时间间隔/秒";
        timeIntervalTextFeild.keyboardType = UIKeyboardTypeNumberPad;
        objc_setAssociatedObject(self, &kf_BaseMsgContentViewControllerTimeIntervalTextFeildKey, timeIntervalTextFeild, OBJC_ASSOCIATION_RETAIN);
    }
    return timeIntervalTextFeild;
}
%new
- (UIBarButtonItem *)kf_bomdItem{

    UIBarButtonItem *bomdItem = objc_getAssociatedObject(self, &kf_BaseMsgContentViewControllerBomdItemKey);
    if(bomdItem == nil){
        bomdItem = [[UIBarButtonItem alloc] initWithTitle:@"轰炸" style:UIBarButtonItemStylePlain target:self  action:@selector(addBombMessageView)];
        objc_setAssociatedObject(self, &kf_BaseMsgContentViewControllerBomdItemKey, bomdItem, OBJC_ASSOCIATION_RETAIN);
    }
    return bomdItem;

}
%new
- (UIButton *)kf_startButton{
    UIButton *startButton = objc_getAssociatedObject(self, &kf_BaseMsgContentViewControllerStartButtonKey);
    if(startButton == nil){
        startButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 170, 270, 30)];
        [startButton setTitle:@"开始" forState:UIControlStateNormal];
        [startButton addTarget:self  action:@selector(hiddenBombMessageViewWithSender:) forControlEvents:UIControlEventTouchUpInside];
        [startButton setTitleColor:[[UIColor greenColor] colorWithAlphaComponent:0.7] forState:UIControlStateNormal];
        objc_setAssociatedObject(self, &kf_BaseMsgContentViewControllerStartButtonKey, startButton, OBJC_ASSOCIATION_RETAIN);
    }
    return startButton;
}


%new
- (NSNumber *)kf_currentTimes{
    NSNumber * times = objc_getAssociatedObject(self, &kf_BaseMsgContentViewControllerCurrentCountKey);
    if(times == nil){
        times = @(0);
        objc_setAssociatedObject(self, &kf_BaseMsgContentViewControllerCurrentCountKey, times, OBJC_ASSOCIATION_RETAIN);
    }
    return times;
}
%new
- (void)kf_setCurrentCount:(NSNumber *)number{
    objc_setAssociatedObject(self, &kf_BaseMsgContentViewControllerCurrentCountKey, number, OBJC_ASSOCIATION_RETAIN);

}


%end




