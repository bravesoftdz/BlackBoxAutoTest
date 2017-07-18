#ifndef DOBOTTYPE_H
#define DOBOTTYPE_H


/*********************************************************************************************************
** Data structures
*********************************************************************************************************/

/*********************************************************************************************************
** Common parts
*********************************************************************************************************/
#pragma pack(push)
#pragma pack(1)

/*
 * Real-time pose
 */
typedef struct tagPose {
    float x;
    float y;
    float z;
    float r;
    float jointAngle[4];
}Pose;

/*
 * Kinematics parameters
 */
typedef struct tagKinematics {
    float velocity;
    float acceleration;
}Kinematics;

/*
 * HOME related
 */
typedef struct tagHOMEParams {
    float x;
    float y;
    float z;
    float r;
}HOMEParams;

typedef struct tagHOMECmd {
    unsigned int reserved;
}HOMECmd;

/*
 * Hand hold teach
 */
typedef enum tagHHTTrigMode {
    TriggeredOnKeyReleased,
    TriggeredOnPeriodicInterval
}HHTTrigMode;

/*
 * End effector
 */
typedef struct tagEndEffectorParams {
    float xBias;
    float yBias;
    float zBias;
}EndEffectorParams;

/*
 * Arm orientation
 */
typedef enum tagArmOrientation {
    LeftyArmOrientation,
    RightyArmOrientation,
}ArmOrientation;

/*
 * JOG related
 */
typedef struct tagJOGJointParams {
    float velocity[4];
    float acceleration[4];
}JOGJointParams;

typedef struct tagJOGCoordinateParams {
    float velocity[4];
    float acceleration[4];
}JOGCoordinateParams;

typedef struct tagJOGCommonParams {
    float velocityRatio;
    float accelerationRatio;
}JOGCommonParams;

enum {
    JogIdle,
    JogAPPressed,
    JogANPressed,
    JogBPPressed,
    JogBNPressed,
    JogCPPressed,
    JogCNPressed,
    JogDPPressed,
    JogDNPressed,
    JogEPPressed,
    JogENPressed
};

typedef struct tagJOGCmd {
    unsigned char isJoint;
    unsigned char cmd;
}JOGCmd;

/*
 * PTP related
 */
typedef struct tagPTPJointParams {
    float velocity[4];
    float acceleration[4];
}PTPJointParams;

typedef struct tagPTPCoordinateParams {
    float xyzVelocity;
    float rVelocity;
    float xyzAcceleration;
    float rAcceleration;
}PTPCoordinateParams;

typedef struct tagPTPJumpParams {
    float jumpHeight;
    float zLimit;
}PTPJumpParams;

typedef struct tagPTPCommonParams {
    float velocityRatio;
    float accelerationRatio;
}PTPCommonParams;

enum PTPMode {
    PTPJUMPXYZMode,
    PTPMOVJXYZMode,
    PTPMOVLXYZMode,

    PTPJUMPANGLEMode,
    PTPMOVJANGLEMode,
    PTPMOVLANGLEMode,

    PTPMOVJANGLEINCMode,
    PTPMOVLXYZINCMode,
    PTPMOVJXYZINCMode,

    PTPJUMPMOVLXYZMode,
};

typedef struct tagPTPCmd {
    unsigned char ptpMode;
    float x;
    float y;
    float z;
    float r;
}PTPCmd;




typedef struct tagWAITCmd {
    unsigned int timeout;
}WAITCmd;




typedef struct tagUserParams{
    float params[8];
}UserParams;

/*********************************************************************************************************
** API result
*********************************************************************************************************/
enum DobotConnectState{
    DobotConnect_NoError,
    DobotConnect_NotFound,
    DobotConnect_Occupied
};

enum DobotCommunicateState{
    DobotCommunicate_NoError,
    DobotCommunicate_BufferFull,
    DobotCommunicate_Timeout,
    DobotCommunicate_InvalidParams
};

#pragma pack(pop)
#endif
