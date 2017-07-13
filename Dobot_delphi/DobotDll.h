#ifndef DOBOTDLL_H
#define DOBOTDLL_H

#include "DobotType.h"

extern    int DobotExec(void);
extern    int ConnectDobot(const char *portName, unsigned int baudrate);
extern    int SetCmdTimeout(unsigned int cmdTimeout);

// Pose and Kinematics parameters are automatically get
extern    int GetPose(Pose *pose);
extern    int GetPoseEx(Pose *pose);
extern    int ResetPose(bool manual, float rearArmAngle, float frontArmAngle);
extern    int GetKinematics(Kinematics *kinematics);

// HOME
extern    int SetHOMEParams(HOMEParams *homeParams, bool isQueued, unsigned  long long *queuedCmdIndex);
extern    int GetHOMEParams(HOMEParams *homeParams);
extern    int SetHOMECmd(HOMECmd *homeCmd, bool isQueued, unsigned  long long *queuedCmdIndex);

// JOG functions
extern    int SetJOGJointParams(JOGJointParams *jointJogParams, bool isQueued, unsigned  long long *queuedCmdIndex);
extern    int GetJOGJointParams(JOGJointParams *jointJogParams);

extern    int SetJOGCoordinateParams(JOGCoordinateParams *coordinateJogParams, bool isQueued, unsigned  long long *queuedCmdIndex);
extern    int GetJOGCoordinateParams(JOGCoordinateParams *coordinateJogParams);

extern    int SetJOGCommonParams(JOGCommonParams *jogCommonParams, bool isQueued, unsigned  long long *queuedCmdIndex);
extern    int GetJOGCommonParams(JOGCommonParams *jogCommonParams);
extern    int SetJOGCmd(JOGCmd *jogCmd, bool isQueued, unsigned  long long *queuedCmdIndex);

// PTP functions
extern    int SetPTPJointParams(PTPJointParams *ptpJointParams, bool isQueued, unsigned  long long *queuedCmdIndex);
extern    int GetPTPJointParams(PTPJointParams *ptpJointParams);
extern    int SetPTPCoordinateParams(PTPCoordinateParams *ptpCoordinateParams, bool isQueued, unsigned  long long *queuedCmdIndex);
extern    int GetPTPCoordinateParams(PTPCoordinateParams *ptpCoordinateParams);
extern    int SetPTPJumpParams(PTPJumpParams *ptpJumpParams, bool isQueued, unsigned  long long *queuedCmdIndex);
extern    int GetPTPJumpParams(PTPJumpParams *ptpJumpParams);
extern    int SetPTPCommonParams(PTPCommonParams *ptpCommonParams, bool isQueued, unsigned  long long *queuedCmdIndex);
extern    int GetPTPCommonParams(PTPCommonParams *ptpCommonParams);

extern    int SetPTPCmd(PTPCmd *ptpCmd, bool isQueued, unsigned  long long *queuedCmdIndex);

// WAIT
extern    int SetWAITCmd(WAITCmd *waitCmd, bool isQueued, unsigned  long long *queuedCmdIndex);

// TEST
extern    int GetUserParams(UserParams *userParams);
extern    int GetPTPTime(PTPCmd *ptpCmd, unsigned int *ptpTime);

// Queued command
extern    int SetQueuedCmdStartExec(void);
extern    int SetQueuedCmdStopExec(void);
extern    int SetQueuedCmdForceStopExec(void);
extern    int SetQueuedCmdStartDownload(unsigned int totalLoop, unsigned int linePerLoop);
extern    int SetQueuedCmdStopDownload(void);
extern    int SetQueuedCmdClear(void);
extern    int GetQueuedCmdCurrentIndex(unsigned  long long *queuedCmdCurrentIndex);

#endif // DOBOTDLL_H
