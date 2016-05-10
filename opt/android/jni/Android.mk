# File: Android.mk
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := ngmap
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libngmap.so
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := ngmapapi
LOCAL_SRC_FILES := src/api_wrap.cpp
LOCAL_SHARED_LIBRARIES := ngmap
include $(BUILD_SHARED_LIBRARY)
