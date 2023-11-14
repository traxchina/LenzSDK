//
//  lenz_stitch_jni.hpp
//  LenzCameraNativeModuleForRN
//
//  Created by lr on 2023/2/8.
//

#ifndef lenz_stitch_jni_hpp
#define lenz_stitch_jni_hpp


#if __cplusplus && __has_include(<opencv2/imgcodecs/ios.h>)

#import <opencv2/core/ocl.hpp>
#import <opencv2/opencv.hpp>

//using namespace cv;
//using namespace std;


/**
 * 输入：
 *      jlong image: 帧数据
 *      jint direction：当前选定的拼接方向，0异形拼，1上，2下，3左，4右
 *      jint is_last_one: 是否为最后一帧, 0不是，1是
 * 输出：
 *      jintArray: [拼接状态，是否需要存图]
 *       拼接状态：
 *          -1: 拍摄完成后拼接大图失败
 *          0: 拍摄过程中产生拼接缩略图失败
 *          1: 拼接成功
 *          2: 特征点变少，放慢速度
 *          3: 特征点极少，即将失败
 *          4：当前拍摄固定了方向，请勿往反方向移动
 *       是否需要存图：
 *          0：不需要
 *          1：需要
*/
int* videoStitch(cv::Mat mat, int direction, int is_last_one);


int resetStitch(const char * input_path);
const char * getCurrentPanoramaShow(void);

const char* getTestCurrentPanoramaShow(void);

cv::Mat getCurrentPanoramsShowMat(void);

#endif


#endif


