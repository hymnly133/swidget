import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import "../common/" 1.0

//################################组件介绍###################################
//# 																		#
//# 		适用于Sapphire的qml音乐卡片———bcsMusicCard_v2.1.0				#
//#			作者：buchaosi													#
//# 		下载：Sapphire 官方 QQ 群群文件 ——"第三方组件"文件夹			#
//# 		本组件完全免费，若您为付费下载请立即举报						#
//# 																		#
//# 		已适配Qt6和新的SWidget系统										#
//# 																		#
//###########################################################################

SWidget {
    id: root
    
//################################设置与全局信息################################
    //组件ID-请勿修改（使用root作为ID）
	
    // 组件圆角-匹配Sapphire圆角
    property int cardRadius: unitRadius || 20
	
    // 组件边框
    property int borderWidth: 1			 //边框大小
    property color borderColor: themeColor //边框颜色-在主题颜色中修改
	
	// 功能开关
    property bool showCover: true				 // 控制封面是否显示
	property bool transparentBackground: false	 // 透明背景
	property bool showbackground: true			 // 切换封面背景是否显示
    property bool useCustomBackground: false     // 切换是否使用自定义背景图片（会覆盖封面背景）
    property string customBackgroundPath: "Background.jpg"     // 自定义背景图片文件（请放在组件同目录下）
	property bool showplaybackProgress: true	 // 切换进度条是否显示
	property bool showplaybackProgressTime: true // 切换进度条时间是否显示
	property bool showbutton: true				 // 切换是否显示按钮
    property bool autoIncrementProgress: true	 // 切换是否启用自动进度条
    property int timeOffset: 0                   // 设置初始时间用于减小误差（秒）
    
    // 布局设置
    property bool verticalLayout: false          // 切换竖版布局（true: 竖版，false: 横版）

    // 显示封面
    property real noCoverMargin: 20 	// 关闭封面时的边距
    property real imageContainer_width: 110		//封面宽
    property real imageContainer_height: 110	//封面高
    property real imageContainer_radius: 18		//封面圆角
	property real imageContainer_zoom: 1.06 	//封面聚焦缩放
    property color shadowColor: "#80000000"   // 阴影颜色
    property real shadowRadius: 10            // 阴影半径
    property real shadowSamples: 15           // 阴影样本数
    property real shadowHorizontalOffset: 3   // 阴影水平偏移
    property real shadowVerticalOffset: 3     // 阴影垂直偏移
    property bool imageContainer_mipmap: true 	//mipmap过滤
    property bool imageContainer_smooth: true 	//平滑过滤

    // 封面背景
    property real backgroundContainer_opacity: 0.6 //封面背景不透明度
    property bool backgroundContainer_mipmap: true //mipmap过滤
    property bool backgroundContainer_smooth: true //平滑过滤

    // 内容大小
    property real titleFontSize: 18			//标题文本大小
    property real artistFontSize: 14    	//艺术家文本大小
    property real timeFontSize: 10			//时间文本大小
	property real button_zoom: 1.06 		//按钮聚焦缩放
    property real playButton_width_true: 48		//播放按钮宽
    property real playButton_height_true: 48	//播放按钮高
    property real button_Width_true: 42			//上下曲宽
    property real button_height_true: 42		//上下曲高
    property real playbackProgress_height: 3.5 //进度条高
    
    // 内容物间距
	property real fontinterval: -1			//文字间距
    property real textProgressSpacing: 0       // 文字与进度条之间距
    property real buttonProgressSpacing: -8    // 控制按钮与进度条间距
    property real verticalSpacing: 8          // 封面与主体元素间距（竖版布局）

    // 主题颜色
    property color themeColor: "#cccccc"    //边框
    property color textColor: "#FFFFFF"		//标题文本
    property color textColor_2: "#FFFFFF"	//艺术家文本
    property color textColor_3: "#FFFFFF"	//时间文本
    property color prevButtonColor: "#FFFFFF"			//上一曲
    property color playPauseButtonColor: "#FFFFFF"		//暂停/播放
    property color nextButtonColor: "#FFFFFF"			//下一曲
    property color playbackProgress_0: "#404040"	//进度条未加载
    property color playbackProgress_1: "#43CBFF" 	//进度条渐变_1
    property color playbackProgress_2: "#9708CC" 	//进度条渐变_2
    property color playbackProgress_3: "#FB016D"	//进度条渐变_3
    property color gradientColor_1: "#3a3a3a" 	//背景渐变覆盖_1
    property color gradientColor_2: "#2a2a2a"	//背景渐变覆盖_2
    property color gradientColor_3: "#1a1a1a"	//背景渐变覆盖_3

    // 渐变过渡设置
    property bool enableSmoothTransitions: true  // 启用平滑过渡
    property int transitionDuration: 300         // 过渡动画持续时间

//##############################################################################

    // 实现代码请勿修改 - 适配新的SWidget系统
    property string currentSongTitle: root.smtcMediaTitle || "未知标题"
    property string currentArtist: root.smtcMediaArtist || "未知艺术家"
    property real playbackProgress: root.smtcPlaybackProgress || 0
    property int playbackPosition: root.smtcPlaybackPosition || 0
    property int playbackDuration: root.smtcPlaybackDuration || 0
    property bool canSkipPrevious: root.smtcCanSkipPrevious || false
    property bool canSkipNext: root.smtcCanSkipNext || false
    property bool canPlay: root.smtcCanPlay || false
    property bool canPause: root.smtcCanPause || false
    property real playButton_width: showbutton ? playButton_width_true : 0 
    property real playButton_height: showbutton ? playButton_height_true : 0
    property real button_width: showbutton ? button_Width_true : 0
    property real button_height: showbutton ? button_height_true : 0
    property color gradientColor1: transparentBackground ? "transparent" : gradientColor_1
    property color gradientColor2: transparentBackground ? "transparent" : gradientColor_2
    property color gradientColor3: transparentBackground ? "transparent" : gradientColor_3
    
    // 自动增加时间模式相关属性-实现代码请勿修改
    property int autoIncrementPosition: timeOffset * 1000  // 初始化为时间误差
    property bool wasPlaying: false
    property string lastSongTitle: ""
    property int lastPlaybackDuration: 0
    property bool receivedExternalUpdate: false // 标记是否接收到外部时间更新
    property int lastExternalPosition: 0 // 记录最后一次外部更新的位置
    
    // 封面更新相关属性
    property string lastAlbumArtBase64: ""
	
    // 设置SWidget属性
    globalRoundCornerEnabled: false
    fpsDisplayMode: SWidget.FpsDisplayMode.Never

//######################################背景####################################
	
    // 主内容容器
    Rectangle {
        id: mainContainer
        anchors.fill: parent
        radius: root.cardRadius
        border.width: root.borderWidth
        border.color: root.borderColor
        color: "transparent"

        // 延迟更新专辑封面的计时器
        Timer {
            id: delayedAlbumArtUpdate
            interval: 300
            onTriggered: updateAlbumArt()
        }

        // 自动增加时间的计时器
        Timer {
            id: autoIncrementTimer
            interval: 1000
            running: autoIncrementProgress && root.smtcPlaybackStatus === "播放中"
            repeat: true
            onTriggered: {
                if (autoIncrementPosition < playbackDuration) {
                    autoIncrementPosition += 1000;
                    receivedExternalUpdate = false;
                } else {
                    autoIncrementPosition = timeOffset * 1000;
                    if (root.smtcPlaybackStatus === "播放中") {
                        autoIncrementTimer.restart();
                    }
                }
            }
        }

        // 横版封面渐变过渡动画
        SequentialAnimation {
            id: coverTransitionAnimation
            running: false

            ParallelAnimation {
                NumberAnimation {
                    target: centerImageCurrent
                    property: "opacity"
                    to: 0
                    duration: enableSmoothTransitions ? transitionDuration : 0
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: centerImageNext
                    property: "opacity"
                    to: 1
                    duration: enableSmoothTransitions ? transitionDuration : 0
                    easing.type: Easing.OutQuad
                }
            }
            ScriptAction {
                script: {
                    // 交换图片角色
                    centerImageCurrent.source = centerImageNext.source;
                    centerImageNext.source = "";
                    centerImageCurrent.opacity = 1;
                    centerImageNext.opacity = 0;

                    // 强制垃圾回收
                    if (typeof gc === 'function') {
                        gc();
                    }
                }
            }
        }

        // 竖版封面渐变过渡动画
        SequentialAnimation {
            id: verticalCoverTransitionAnimation
            running: false

            ParallelAnimation {
                NumberAnimation {
                    target: verticalCenterImageCurrent
                    property: "opacity"
                    to: 0
                    duration: enableSmoothTransitions ? transitionDuration : 0
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: verticalCenterImageNext
                    property: "opacity"
                    to: 1
                    duration: enableSmoothTransitions ? transitionDuration : 0
                    easing.type: Easing.OutQuad
                }
            }
            ScriptAction {
                script: {
                    // 交换图片角色
                    verticalCenterImageCurrent.source = verticalCenterImageNext.source;
                    verticalCenterImageNext.source = "";
                    verticalCenterImageCurrent.opacity = 1;
                    verticalCenterImageNext.opacity = 0;

                    // 强制垃圾回收
                    if (typeof gc === 'function') {
                        gc();
                    }
                }
            }
        }

        // 背景渐变过渡动画
        SequentialAnimation {
            id: backgroundTransitionAnimation
            running: false

            ParallelAnimation {
                NumberAnimation {
                    target: backgroundAlbumArtCurrent
                    property: "opacity"
                    to: 0
                    duration: enableSmoothTransitions ? transitionDuration : 0
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: backgroundAlbumArtNext
                    property: "opacity"
                    to: backgroundContainer_opacity
                    duration: enableSmoothTransitions ? transitionDuration : 0
                    easing.type: Easing.OutQuad
                }
            }
            ScriptAction {
                script: {
                    backgroundAlbumArtCurrent.source = backgroundAlbumArtNext.source;
                    backgroundAlbumArtNext.source = "";
                    backgroundAlbumArtCurrent.opacity = backgroundContainer_opacity;
                    backgroundAlbumArtNext.opacity = 0;

                    if (typeof gc === 'function') {
                        gc();
                    }
                }
            }
        }
        // 专辑封面背景
        Item {
            anchors.fill: parent
            visible: showbackground && !transparentBackground
            Item {
                id: backgroundContainer
                anchors.fill: parent
                layer.enabled: true
                layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: backgroundContainer.width
                            height: backgroundContainer.height
                            radius: root.cardRadius
                        }
                }
                
                // 背景图片容器 - 使用两个图片实现渐变过渡
                Item {
                    anchors.fill: parent
                    
                    // 当前显示的背景图片
                    Image {
                        id: backgroundAlbumArtCurrent
                        source: getMusicSource()
                        fillMode: Image.PreserveAspectCrop
                        anchors.fill: parent
                        smooth: backgroundContainer_smooth
                        mipmap: backgroundContainer_mipmap
                        asynchronous: true
                        sourceSize: Qt.size(1000, 1000)
                        opacity: backgroundContainer_opacity
                    }
                    
                    // 下一张背景图片（用于过渡）
                    Image {
                        id: backgroundAlbumArtNext
                        source: ""
                        fillMode: Image.PreserveAspectCrop
                        anchors.fill: parent
                        smooth: backgroundContainer_smooth
                        mipmap: backgroundContainer_mipmap
                        asynchronous: true
                        sourceSize: Qt.size(1000, 1000)
                        opacity: 0
                    }
                }
            }
        }
        
        gradient: Gradient {
             GradientStop { position: 0.0; color: gradientColor1 }
             GradientStop { position: 0.5; color: gradientColor2 }
             GradientStop { position: 1.0; color: gradientColor3 }
        }

//########################################主要内容##############################
        Item {
            anchors.fill: parent
            anchors.margins: 12

            // 横版布局
            Item {
                id: horizontalLayout
                anchors.fill: parent
                visible: !verticalLayout

                // 专辑封面容器
                Item {
                    id: shadowContainer
                    width: showCover ? (imageContainer_width + shadowRadius * 2) : 0
                    height: showCover ? (imageContainer_height + shadowRadius * 2) : 0
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: showCover ? -shadowRadius : 0
                        verticalCenterOffset: -shadowVerticalOffset / 2
                    }
                    
                    // 阴影效果
                    layer.enabled: showCover
                    layer.effect: DropShadow {
                        color: shadowColor
                        radius: shadowRadius
                        samples: shadowSamples
                        horizontalOffset: shadowHorizontalOffset
                        verticalOffset: shadowVerticalOffset
                    }

                    // 专辑封面
                    Rectangle {
                        id: imageContainer
                        width: showCover ? imageContainer_width : 0
                        height: showCover ? imageContainer_height : 0
                        radius: imageContainer_radius
                        color: "transparent" 
                        anchors.centerIn: parent
                        visible: showCover

                        // 圆角裁剪
                        layer.enabled: showCover
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: imageContainer.width
                                height: imageContainer.height
                                radius: imageContainer.radius
                            }
                        }
                        
                        // 封面图片容器 - 使用两个图片实现渐变过渡
                        Item {
                            anchors.fill: parent
                            
                            // 当前显示的封面图片
                            Image {
                                id: centerImageCurrent
                                anchors.fill: parent
                                source: getMusicSource()
                                cache: true
                                mipmap: imageContainer_mipmap
                                smooth: imageContainer_smooth
                                asynchronous: true
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(imageContainer.width * 2, imageContainer.height * 2)
                                visible: showCover
                            }
                            
                            // 下一张封面图片（用于过渡）
                            Image {
                                id: centerImageNext
                                anchors.fill: parent
                                source: ""
                                cache: true
                                mipmap: imageContainer_mipmap
                                smooth: imageContainer_smooth
                                asynchronous: true
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(imageContainer.width * 2, imageContainer.height * 2)
                                visible: showCover
                                opacity: 0
                            }
                        }
                        
                        // 鼠标悬停效果
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: showCover
                            onEntered: {
                                if (centerImageCurrent.status === Image.Ready && showCover) {
                                    shadowContainer.scale = imageContainer_zoom;
                                }
                            }
                            onExited: {
                                shadowContainer.scale = 1.0;
                            }
                        }
                        
                        // 加载指示器
                        Rectangle {
                            anchors.fill: parent
                            color: "#10000000"
                            radius: imageContainer.radius
                            visible: centerImageCurrent.status === Image.Loading && showCover
                            
                            BusyIndicator {
                                anchors.centerIn: parent
                                running: true
                                width: Math.min(parent.width, parent.height) * 0.4
                                height: width
                            }
                        }
                    }
                    
                    // 过渡动画
                    Behavior on scale {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }

                // 右侧内容区域
                Column {
                    id: rightContent
                    anchors {
                        left: showCover ? shadowContainer.right : parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: showCover ? 10 : noCoverMargin
                        rightMargin: showCover ? 10 : noCoverMargin
                    }
                    spacing: 8
                    
					// 滚动文本实现
					component ScrollingText: Item {
						id: scrollingTextRoot
						width: parent.width
						height: textMetrics.height + fontinterval
						clip: true
							
						property string text: ""
						property int fontSize
						property bool isBold: false
						property color textColor
						property bool scrolling: false
						property bool isScrolling: false
						
						// 滚动动画相关属性
						property real scrollOffset: 0
						property real scrollSpeed: 30 // 像素/秒
						property real pauseDuration: 100 // 开始滚动前的暂停时间（毫秒）
						
						// 状态管理
						property bool hasScrolled: false // 标记是否已经滚动过一次
						property real totalScrollDistance: 0 // 需要滚动的总距离
						
						// 文本度量
						TextMetrics {
							id: textMetrics
							font.pixelSize: scrollingTextRoot.fontSize
							font.bold: scrollingTextRoot.isBold
							text: "Áy"
						}
						
						// 主文本显示
						Text {
							id: textItem1
							anchors.verticalCenter: parent.verticalCenter
							text: scrollingTextRoot.text
							font.pixelSize: scrollingTextRoot.fontSize
							font.bold: scrollingTextRoot.isBold
							color: textColor
							x: scrollingTextRoot.scrollOffset
							
							layer.enabled: true
							layer.effect: DropShadow {
								color: "#80000000"
								radius: 1
								samples: 3
								horizontalOffset: 1
								verticalOffset: 1
							}
						}
						
						// 第二个文本用于无缝滚动
						Text {
							id: textItem2
							anchors.verticalCenter: parent.verticalCenter
							text: scrollingTextRoot.text
							font.pixelSize: scrollingTextRoot.fontSize
							font.bold: scrollingTextRoot.isBold
							color: textColor
							x: textItem1.x + textItem1.width + 50 // 两个文本之间的间距
							visible: scrollingTextRoot.scrolling
							
							layer.enabled: true
							layer.effect: DropShadow {
								color: "#80000000"
								radius: 1
								samples: 3
								horizontalOffset: 1
								verticalOffset: 1
							}
						}
						
						// 滚动动画计时器
						Timer {
							id: scrollTimer
							interval: 16 // 约60fps
							running: scrollingTextRoot.isScrolling
							repeat: true
							onTriggered: {
								scrollingTextRoot.scrollOffset -= (scrollSpeed * interval / 1000);
								scrollingTextRoot.totalScrollDistance += (scrollSpeed * interval / 1000);
								
								// 检查是否滚动完成（第二个文本的开头已经滚动到视口的开头）
								// 我们需要滚动直到第二个文本的开头与视口左侧对齐
								if (scrollingTextRoot.totalScrollDistance >= textItem1.width + 50) {
									stopScrolling();
								}
							}
						}
						
						// 开始滚动前的暂停计时器
						Timer {
							id: pauseTimer
							interval: pauseDuration
							running: false
							onTriggered: {
								startScrolling();
							}
						}
						
						// 重置计时器
						Timer {
							id: resetTimer
							interval: 1000 // 滚动完成后等待1秒再重置
							running: false
							onTriggered: {
								resetScrollingState();
							}
						}
						
						// 鼠标悬停处理
						HoverHandler {
							onHoveredChanged: {
								if (hovered && scrollingTextRoot.scrolling && !scrollingTextRoot.isScrolling && !scrollingTextRoot.hasScrolled) {
									// 鼠标悬停时开始滚动（先暂停一会）
									scrollingTextRoot.hasScrolled = true;
									pauseTimer.restart();
								}
							}
						}
						
						// 开始滚动
						function startScrolling() {
							scrollingTextRoot.isScrolling = true;
							scrollingTextRoot.totalScrollDistance = 0;
							scrollTimer.restart();
						}
						
						// 停止滚动
						function stopScrolling() {
							scrollingTextRoot.isScrolling = false;
							scrollTimer.stop();
							// 延迟一会后重置状态
							resetTimer.restart();
						}
						
						// 重置滚动状态
						function resetScrollingState() {
							scrollingTextRoot.isScrolling = false;
							scrollingTextRoot.scrollOffset = 0;
							scrollingTextRoot.totalScrollDistance = 0;
							scrollingTextRoot.hasScrolled = false;
							pauseTimer.stop();
							scrollTimer.stop();
							resetTimer.stop();
						}
						
						// 检查是否需要滚动
						function checkScrollNeeded() {
							if (textItem1.width === 0) return;
							var needsScroll = textItem1.width > width;
							if (needsScroll !== scrollingTextRoot.scrolling) {
								scrollingTextRoot.scrolling = needsScroll;
								if (!needsScroll) {
									resetScrollingState();
								}
							}
						}
						
						onTextChanged: {
							resetScrollingState();
							// 延迟检查，确保文本已经渲染
							Qt.callLater(checkScrollNeeded);
						}
						onWidthChanged: {
							Qt.callLater(checkScrollNeeded);
						}
						
						Component.onCompleted: {
							Qt.callLater(checkScrollNeeded);
						}
					}
                    // 标题滚动文本组件
                    ScrollingText {
                        id: titleScroll
                        text: currentSongTitle
                        fontSize: titleFontSize
                        textColor: root.textColor
                        isBold: true
                    }

                    // 艺术家名称滚动文本组件
                    ScrollingText {
                        id: artistScroll
                        text: currentArtist
                        fontSize: artistFontSize
                        textColor: root.textColor_2
                        isBold: false
                    }
                    
                    // 文字与进度条之间的间距
                    Item {
                        width: parent.width
                        height: textProgressSpacing
                    }
                    
                    // 进度条区域
                    Column {
                        width: parent.width
                        spacing: 4
                        
                        // 进度条
                        Rectangle {
                            width: parent.width
                            height: showplaybackProgress ? playbackProgress_height : 0
                            radius: 2
                            color: playbackProgress_0
                            
                            // 进度填充
                            Rectangle {
                                width: parent.width * (getDisplayProgress() / 100)
                                height: parent.height
                                radius: parent.radius
                                
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: playbackProgress_1 }
                                    GradientStop { position: 0.5; color: playbackProgress_2 }
                                    GradientStop { position: 1.0; color: playbackProgress_3 }
                                }
                                
                                layer.enabled: true
                                layer.effect: Glow {
                                    color: themeColor
                                    radius: 2
                                    samples: 6
                                }
                            }
                        }
                        
                        // 时间信息
                        Row {
                            width: parent.width
                            
                            Text {
                                id: timeLeft
                                text: showplaybackProgressTime ? formatTime(getDisplayPosition()) : ""
                                color: textColor_3
                                font.pixelSize: timeFontSize
                            }
                            
                            Item {
                                width: parent.width - (timeLeft.width + timeRight.width)
                                height: 1
                            }
                            
                            Text {
                                id: timeRight
                                text: showplaybackProgressTime ? formatTime(playbackDuration) : ""
                                color: textColor_3
                                font.pixelSize: timeFontSize
                            }
                        }
                    }
                    
                    // 按钮与进度条间距
                    Item {
                        width: parent.width
                        height: buttonProgressSpacing
                    }
                    
                    // 按钮行
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 15
                   
                        // 按钮组件
                        component ControlButton: RoundButton {
                            property alias buttonBg: bgRect
                            property bool isPlayButton: false
                            
                            width: isPlayButton ? playButton_width : button_width
                            height: isPlayButton ? playButton_height : button_height
                            
                            // 玻璃效果背景
                            background: Rectangle {
                                id: bgRect
                                anchors.fill: parent
                                radius: parent.width / 2
                                color: parent.enabled ? "#60FFFFFF" : "#30FFFFFF"
                                opacity: 0.5
                                border.width: 1
                                border.color: parent.enabled ? "#80FFFFFF" : "#40FFFFFF"
                            }
                            
                            // 悬停效果
                            HoverHandler {
                                onHoveredChanged: {
                                    if (hovered && parent.enabled) {
                                        parent.scale = button_zoom;
                                        bgRect.color = "#80FFFFFF";
                                    } else {
                                        parent.scale = 1.0;
                                        bgRect.color = parent.enabled ? "#60FFFFFF" : "#30FFFFFF";
                                    }
                                }
                            }
                            
                            Behavior on scale {
                                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        // 上一曲按钮
                        ControlButton {
                            id: prevButton
                            contentItem: Item {
                                anchors.centerIn: parent                 
                                Canvas {
                                    id: prevIcon
                                    anchors.centerIn: parent
                                    width: button_width/2.1
                                    height: button_height/2.1
                                    antialiasing: true
                                    
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.fillStyle = prevButtonColor;
                                        ctx.fillRect(width/4, height/5, width/10, height/1.66);
                                        ctx.beginPath();
                                        ctx.moveTo(width/1.25, height/5);
                                        ctx.lineTo(width/3.33, height/2);
                                        ctx.lineTo(width/1.25, height/1.25);
                                        ctx.closePath();
                                        ctx.fill();
                                    }
                                }
                            }
                            
                            onClicked: {
                                root.skipSMTCPrevious();
                                resetAutoIncrement();
                            }
                        }
                        
                        // 播放/暂停按钮
                        ControlButton {
                            id: playPauseButton
                            isPlayButton: true
                            enabled: canPlay || canPause
                            property string playbackStatus: root.smtcPlaybackStatus
                            
                            contentItem: Item {
                                anchors.centerIn: parent
                                Canvas {
                                    id: playPauseIcon
                                    anchors.centerIn: parent
                                    width: playButton_width/2.4
                                    height: playButton_width/2.4
                                    antialiasing: true
                                    
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.fillStyle = playPauseButtonColor;
                                        
                                        if (playPauseButton.playbackStatus === "播放中") {
                                            ctx.fillRect(width/5, height/6.66, width/5, height - height/4);
                                            ctx.fillRect(width/1.66, height/6.66, width/5, height - height/4);
                                        } else {
                                            ctx.beginPath();
                                            ctx.moveTo(width/5, height/10);
                                            ctx.lineTo(width - width/10, height/2);
                                            ctx.lineTo(width/5, height - height/10);
                                            ctx.closePath();
                                            ctx.fill();
                                        }
                                    }
                                }
                            }
                            
                            Connections {
                                target: root
                                function onSmtcPlaybackStatusChanged() {
                                    playPauseButton.playbackStatus = root.smtcPlaybackStatus;
                                    playPauseIcon.requestPaint();
                                    handlePlaybackStatusChange();
                                }
                            }
                            
                            onEnabledChanged: playPauseIcon.requestPaint();
                            
                            onClicked: {
                                if (root.smtcPlaybackStatus === "播放中" && canPause) {
                                    root.pauseSMTCMedia();
                                } else if (canPlay) {
                                    root.playSMTCMedia();
                                }
                            }
                        }
                        
                        // 下一曲按钮
                        ControlButton {
                            id: nextButton
                            contentItem: Item {
                                anchors.centerIn: parent
                                Canvas {
                                    id: nextIcon
                                    anchors.centerIn: parent
                                    width: button_width/2.1
                                    height: button_height/2.1
                                    antialiasing: true
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.fillStyle = nextButtonColor;
                                        ctx.fillRect(width/1.66, height/5, width/10, height/1.66);
                                        ctx.beginPath();
                                        ctx.moveTo(width/6.66, height/5);
                                        ctx.lineTo(width/1.53, height/2);
                                        ctx.lineTo(width/6.66, height/1.25);
                                        ctx.closePath();
                                        ctx.fill();
                                    }
                                }
                            }
                            
                            onClicked: {
                                root.skipSMTCNext();
                                resetAutoIncrement();
                            }
                        }
                    }
                }
            }

            // 竖版布局
            Item {
                id: verticalLayoutContainer
                anchors.fill: parent
                visible: root.verticalLayout

                // 垂直居中容器
                Column {
                    id: verticalContent
                    width: parent.width
                    spacing: verticalSpacing
                    anchors.verticalCenter: parent.verticalCenter

                    // 专辑封面容器
                    Item {
                        id: verticalShadowContainer
                        width: showCover ? (imageContainer_width + shadowRadius * 2) : 0
                        height: showCover ? (imageContainer_height + shadowRadius * 2) : 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: showCover
                        
                        layer.enabled: showCover
                        layer.effect: DropShadow {
                            color: shadowColor
                            radius: shadowRadius
                            samples: shadowSamples
                            horizontalOffset: shadowHorizontalOffset
                            verticalOffset: shadowVerticalOffset
                        }

                        // 专辑封面
                        Rectangle {
                            id: verticalImageContainer
                            width: showCover ? imageContainer_width : 0
                            height: showCover ? imageContainer_height : 0
                            radius: imageContainer_radius
                            color: "transparent" 
                            anchors.centerIn: parent
                            visible: showCover

                            layer.enabled: showCover
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: verticalImageContainer.width
                                    height: verticalImageContainer.height
                                    radius: verticalImageContainer.radius
                                }
                            }
                            
                            // 封面图片容器 - 使用两个图片实现渐变过渡
                            Item {
                                anchors.fill: parent
                                
                                // 当前显示的封面图片
                                Image {
                                    id: verticalCenterImageCurrent
                                    anchors.fill: parent
                                    source: getMusicSource()
                                    cache: true
                                    mipmap: imageContainer_mipmap
                                    smooth: imageContainer_smooth
                                    asynchronous: true
                                    fillMode: Image.PreserveAspectCrop
                                    sourceSize: Qt.size(verticalImageContainer.width * 2, verticalImageContainer.height * 2)
                                    visible: showCover
                                }
                                
                                // 下一张封面图片（用于过渡）
                                Image {
                                    id: verticalCenterImageNext
                                    anchors.fill: parent
                                    source: ""
                                    cache: true
                                    mipmap: imageContainer_mipmap
                                    smooth: imageContainer_smooth
                                    asynchronous: true
                                    fillMode: Image.PreserveAspectCrop
                                    sourceSize: Qt.size(verticalImageContainer.width * 2, verticalImageContainer.height * 2)
                                    visible: showCover
                                    opacity: 0
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: showCover
                                onEntered: {
                                    if (verticalCenterImageCurrent.status === Image.Ready && showCover) {
                                        verticalShadowContainer.scale = imageContainer_zoom;
                                    }
                                }
                                onExited: verticalShadowContainer.scale = 1.0;
                            }
                            
                            Rectangle {
                                anchors.fill: parent
                                color: "#10000000"
                                radius: verticalImageContainer.radius
                                visible: verticalCenterImageCurrent.status === Image.Loading && showCover
                                
                                BusyIndicator {
                                    anchors.centerIn: parent
                                    running: true
                                    width: Math.min(parent.width, parent.height) * 0.4
                                    height: width
                                }
                            }
                        }
                        
                        Behavior on scale {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }

                    // 竖版内容区域
                    Column {
                        width: parent.width
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter

                        // 标题
                        ScrollingText {
                            id: verticalTitleScroll
                            text: currentSongTitle
                            fontSize: titleFontSize
                            textColor: root.textColor
                            isBold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        // 艺术家
                        ScrollingText {
                            id: verticalArtistScroll
                            text: currentArtist
                            fontSize: artistFontSize
                            textColor: root.textColor_2
                            isBold: false
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        // 间距
                        Item {
                            width: parent.width
                            height: textProgressSpacing
                        }
                        
                        // 进度条区域
                        Column {
                            width: parent.width
                            spacing: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            // 进度条
                            Rectangle {
                                width: parent.width
                                height: showplaybackProgress ? playbackProgress_height : 0
                                radius: 2
                                color: playbackProgress_0
                                
                                Rectangle {
                                    width: parent.width * (getDisplayProgress() / 100)
                                    height: parent.height
                                    radius: parent.radius
                                    
                                    gradient: Gradient {
                                        orientation: Gradient.Horizontal
                                        GradientStop { position: 0.0; color: playbackProgress_1 }
                                        GradientStop { position: 0.5; color: playbackProgress_2 }
                                        GradientStop { position: 1.0; color: playbackProgress_3 }
                                    }
                                    
                                    layer.enabled: true
                                    layer.effect: Glow {
                                        color: themeColor
                                        radius: 2
                                        samples: 6
                                    }
                                }
                            }
                            
                            // 时间信息
                            Row {
                                width: parent.width
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Text {
                                    id: verticalTimeLeft
                                    text: showplaybackProgressTime ? formatTime(getDisplayPosition()) : ""
                                    color: textColor_3
                                    font.pixelSize: timeFontSize
                                }
                                
                                Item {
                                    width: parent.width - (verticalTimeLeft.width + verticalTimeRight.width)
                                    height: 1
                                }
                                
                                Text {
                                    id: verticalTimeRight
                                    text: showplaybackProgressTime ? formatTime(playbackDuration) : ""
                                    color: textColor_3
                                    font.pixelSize: timeFontSize
                                }
                            }
                        }
                        
                        // 按钮间距
                        Item {
                            width: parent.width
                            height: buttonProgressSpacing
                        }
                        
                        // 按钮行 - 修复播放暂停按钮绘制
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 15
                       
                            // 上一曲按钮
                            ControlButton {
                                contentItem: Item {
                                    anchors.centerIn: parent                 
                                    Canvas {
                                        anchors.centerIn: parent
                                        width: button_width/2.1
                                        height: button_height/2.1
                                        antialiasing: true
                                        
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            ctx.fillStyle = prevButtonColor;
                                            ctx.fillRect(width/4, height/5, width/10, height/1.66);
                                            ctx.beginPath();
                                            ctx.moveTo(width/1.25, height/5);
                                            ctx.lineTo(width/3.33, height/2);
                                            ctx.lineTo(width/1.25, height/1.25);
                                            ctx.closePath();
                                            ctx.fill();
                                        }
                                    }
                                }
                                
                                onClicked: {
                                    root.skipSMTCPrevious();
                                    resetAutoIncrement();
                                }
                            }
                            
                        // 播放/暂停按钮 - 修复绘制问题
                        ControlButton {
                            id: verticalPlayPauseButton
                            isPlayButton: true
                            enabled: canPlay || canPause
                            property string playbackStatus: root.smtcPlaybackStatus
                            
                            contentItem: Item {
                                anchors.centerIn: parent
                                Canvas {
                                    id: verticalPlayPauseIcon
                                    anchors.centerIn: parent
                                    width: playButton_width/2.4
                                    height: playButton_width/2.4
                                    antialiasing: true
                                    
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.reset();
                                        ctx.fillStyle = playPauseButtonColor;
                                        
                                        if (verticalPlayPauseButton.playbackStatus === "播放中") {
                                            // 暂停图标 (两个竖条)
                                            ctx.fillRect(width/5, height/6.66, width/5, height - height/4);
                                            ctx.fillRect(width/1.66, height/6.66, width/5, height - height/4);
                                        } else {
                                            // 播放图标 (三角形)
                                            ctx.beginPath();
                                            ctx.moveTo(width/5, height/10);
                                            ctx.lineTo(width - width/10, height/2);
                                            ctx.lineTo(width/5, height - height/10);
                                            ctx.closePath();
                                            ctx.fill();
                                        }
                                    }
                                }
                            }
                            
                            Connections {
                                target: root
                                function onSmtcPlaybackStatusChanged() {
                                    verticalPlayPauseButton.playbackStatus = root.smtcPlaybackStatus;
                                    verticalPlayPauseIcon.requestPaint();
                                    handlePlaybackStatusChange();
                                }
                            }
                            
                            onEnabledChanged: verticalPlayPauseIcon.requestPaint();
                            
                            onClicked: {
                                if (root.smtcPlaybackStatus === "播放中" && canPause) {
                                    root.pauseSMTCMedia();
                                } else if (canPlay) {
                                    root.playSMTCMedia();
                                }
                            }
                        }
                            
                            // 下一曲按钮
                            ControlButton {
                                contentItem: Item {
                                    anchors.centerIn: parent
                                    Canvas {
                                        anchors.centerIn: parent
                                        width: button_width/2.1
                                        height: button_height/2.1
                                        antialiasing: true
                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            ctx.fillStyle = nextButtonColor;
                                            ctx.fillRect(width/1.66, height/5, width/10, height/1.66);
                                            ctx.beginPath();
                                            ctx.moveTo(width/6.66, height/5);
                                            ctx.lineTo(width/1.53, height/2);
                                            ctx.lineTo(width/6.66, height/1.25);
                                            ctx.closePath();
                                            ctx.fill();
                                        }
                                    }
                                }
                                
                                onClicked: {
                                    root.skipSMTCNext();
                                    resetAutoIncrement();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // 格式化时间显示
    function formatTime(milliseconds) {
        if (milliseconds <= 0) return "00:00";
        const seconds = Math.floor(milliseconds / 1000);
        const minutes = Math.floor(seconds / 60);
        const remainingSeconds = seconds % 60;
        return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
    }
    
    // 获取显示的进度百分比
    function getDisplayProgress() {
        if (autoIncrementProgress) {
            return playbackDuration > 0 ? (autoIncrementPosition / playbackDuration) * 100 : 0;
        } else {
            return playbackProgress;
        }
    }
    
    // 获取显示的位置时间
    function getDisplayPosition() {
        if (autoIncrementProgress) {
            return autoIncrementPosition;
        } else {
            return playbackPosition;
        }
    }
    
    // 处理播放状态变化
    function handlePlaybackStatusChange() {
        if (autoIncrementProgress) {
            if (root.smtcPlaybackStatus === "播放中") {
                wasPlaying = true;
                if (autoIncrementPosition >= playbackDuration && playbackDuration > 0) {
                    autoIncrementPosition = timeOffset * 1000;
                }
            } else if (wasPlaying) {
                wasPlaying = false;
            }
        }
    }
    
    // 重置自动增加计时
    function resetAutoIncrement() {
        autoIncrementPosition = timeOffset * 1000;
        lastPlaybackDuration = playbackDuration;
        receivedExternalUpdate = false;
        if (autoIncrementProgress && root.smtcPlaybackStatus === "播放中") {
            autoIncrementTimer.restart();
        }
    }
    
    // 获取背景图片源 - 适配新的SWidget系统
    function getMusicSource() {
        if (!showbackground) return "";
        if (useCustomBackground) {
            return customBackgroundPath;
        } else {
            // 使用新的SWidget属性
            return root.smtcHasAlbumArt && root.smtcAlbumArtBase64 ? "data:image/jpeg;base64," + root.smtcAlbumArtBase64 : "";
        }
    }
    
    // 更新横版封面图片
    function updateCoverImage(newSource) {
        if (centerImageNext.source !== "" && coverTransitionAnimation.running) {
            // 如果正在过渡，先完成当前过渡
            coverTransitionAnimation.complete();
        }
        
        if (centerImageCurrent.source !== newSource) {
            centerImageNext.source = newSource;
            coverTransitionAnimation.start();
        }
    }
    
    // 更新竖版封面图片
    function updateVerticalCoverImage(newSource) {
        if (verticalCenterImageNext.source !== "" && verticalCoverTransitionAnimation.running) {
            // 如果正在过渡，先完成当前过渡
            verticalCoverTransitionAnimation.complete();
        }
        
        if (verticalCenterImageCurrent.source !== newSource) {
            verticalCenterImageNext.source = newSource;
            verticalCoverTransitionAnimation.start();
        }
    }
    
    // 更新背景图片（带渐变过渡）
    function updateBackgroundImage(newSource) {
        if (backgroundAlbumArtNext.source !== "" && backgroundTransitionAnimation.running) {
            // 如果正在过渡，先完成当前过渡
            backgroundTransitionAnimation.complete();
        }
        
        if (backgroundAlbumArtCurrent.source !== newSource) {
            backgroundAlbumArtNext.source = newSource;
            backgroundTransitionAnimation.start();
        }
    }
    
    // 更新专辑封面 - 适配新的SWidget系统
    function updateAlbumArt() {
        if (root.smtcHasAlbumArt) {
            var currentAlbumArt = root.smtcAlbumArtBase64;
            if (currentAlbumArt && currentAlbumArt !== lastAlbumArtBase64) {
                var newSource = "data:image/jpeg;base64," + currentAlbumArt;
                updateCoverImage(newSource);
                updateVerticalCoverImage(newSource);
                if (!useCustomBackground) {
                    updateBackgroundImage(newSource);
                }
                lastAlbumArtBase64 = currentAlbumArt;
            } else if (!currentAlbumArt) {
                // 如果没有封面，清空图片
                updateCoverImage("");
                updateVerticalCoverImage("");
                if (!useCustomBackground) {
                    updateBackgroundImage("");
                }
                lastAlbumArtBase64 = "";
            }
        } else {
            // 如果没有封面数据，清空图片
            updateCoverImage("");
            updateVerticalCoverImage("");
            if (!useCustomBackground) {
                updateBackgroundImage("");
            }
            lastAlbumArtBase64 = "";
        }
    }


    // 当播放位置变化时处理外部更新
    onPlaybackPositionChanged: {
        if (autoIncrementProgress) {
            if (playbackPosition !== lastExternalPosition) {
                receivedExternalUpdate = true;
                lastExternalPosition = playbackPosition;
                autoIncrementPosition = playbackPosition;
                
                if (root.smtcPlaybackStatus === "播放中") {
                    autoIncrementTimer.restart();
                }
            }
        }
    }
    

    // 当歌曲变化时更新滚动状态并重置计时
    onCurrentSongTitleChanged: {
        titleScroll.resetScrollingState();
        titleScroll.checkScrollNeeded();
        verticalTitleScroll.resetScrollingState();
        verticalTitleScroll.checkScrollNeeded();
        
        delayedAlbumArtUpdate.restart();
        
        if (autoIncrementProgress && currentSongTitle !== lastSongTitle) {
            resetAutoIncrement();
            lastSongTitle = currentSongTitle;
        }
    }
    
    // 当艺术家变化时更新滚动状态
    onCurrentArtistChanged: {
        artistScroll.resetScrollingState();
        artistScroll.checkScrollNeeded();
        verticalArtistScroll.resetScrollingState();
        verticalArtistScroll.checkScrollNeeded();
    }
    
    // 封面显示状态变化时更新布局
    onShowCoverChanged: {
        titleScroll.resetScrollingState();
        artistScroll.resetScrollingState();
        verticalTitleScroll.resetScrollingState();
        verticalArtistScroll.resetScrollingState();
        titleScroll.checkScrollNeeded();
        artistScroll.checkScrollNeeded();
        verticalTitleScroll.checkScrollNeeded();
        verticalArtistScroll.checkScrollNeeded();
    }
    
    // 布局变化时更新
    onVerticalLayoutChanged: {
        titleScroll.resetScrollingState();
        artistScroll.resetScrollingState();
        verticalTitleScroll.resetScrollingState();
        verticalArtistScroll.resetScrollingState();
        titleScroll.checkScrollNeeded();
        artistScroll.checkScrollNeeded();
        verticalTitleScroll.checkScrollNeeded();
        verticalArtistScroll.checkScrollNeeded();
        
        updateAlbumArt();
    }
    
    // 监听SMTC属性变化
    onSmtcAlbumArtBase64Changed: {
        delayedAlbumArtUpdate.restart();
    }
    
    // 初始化
    Component.onCompleted: {
        lastSongTitle = currentSongTitle;
        lastPlaybackDuration = playbackDuration;
        lastExternalPosition = playbackPosition;
        
        updateAlbumArt();
    }
}

