local ffi = require "ffi"

local lib
if package.ffipath then
	-- try some other options before the OS default:
	local libpath = assert(package.searchpath("glfw", package.ffipath))
	lib = ffi.load(libpath)
else
	lib = ffi.load("glfw")
end

ffi.cdef [[

static const int GLFW_VERSION_MAJOR =          3;
static const int GLFW_VERSION_MINOR =          1;
static const int GLFW_VERSION_REVISION =       0;
static const int GLFW_RELEASE =                0;
static const int GLFW_PRESS =                  1;
static const int GLFW_REPEAT =                 2;
static const int GLFW_KEY_UNKNOWN =            -1;

static const int GLFW_KEY_SPACE =              32;
static const int GLFW_KEY_APOSTROPHE =         39  /* ' */;
static const int GLFW_KEY_COMMA =              44  /* , */;
static const int GLFW_KEY_MINUS =              45  /* - */;
static const int GLFW_KEY_PERIOD =             46  /* . */;
static const int GLFW_KEY_SLASH =              47  /* / */;
static const int GLFW_KEY_0 =                  48;
static const int GLFW_KEY_1 =                  49;
static const int GLFW_KEY_2 =                  50;
static const int GLFW_KEY_3 =                  51;
static const int GLFW_KEY_4 =                  52;
static const int GLFW_KEY_5 =                  53;
static const int GLFW_KEY_6 =                  54;
static const int GLFW_KEY_7 =                  55;
static const int GLFW_KEY_8 =                  56;
static const int GLFW_KEY_9 =                  57;
static const int GLFW_KEY_SEMICOLON =          59  /* ; */;
static const int GLFW_KEY_EQUAL =              61  /* = */;
static const int GLFW_KEY_A =                  65;
static const int GLFW_KEY_B =                  66;
static const int GLFW_KEY_C =                  67;
static const int GLFW_KEY_D =                  68;
static const int GLFW_KEY_E =                  69;
static const int GLFW_KEY_F =                  70;
static const int GLFW_KEY_G =                  71;
static const int GLFW_KEY_H =                  72;
static const int GLFW_KEY_I =                  73;
static const int GLFW_KEY_J =                  74;
static const int GLFW_KEY_K =                  75;
static const int GLFW_KEY_L =                  76;
static const int GLFW_KEY_M =                  77;
static const int GLFW_KEY_N =                  78;
static const int GLFW_KEY_O =                  79;
static const int GLFW_KEY_P =                  80;
static const int GLFW_KEY_Q =                  81;
static const int GLFW_KEY_R =                  82;
static const int GLFW_KEY_S =                  83;
static const int GLFW_KEY_T =                  84;
static const int GLFW_KEY_U =                  85;
static const int GLFW_KEY_V =                  86;
static const int GLFW_KEY_W =                  87;
static const int GLFW_KEY_X =                  88;
static const int GLFW_KEY_Y =                  89;
static const int GLFW_KEY_Z =                  90;
static const int GLFW_KEY_LEFT_BRACKET =       91  /* [ */;
static const int GLFW_KEY_BACKSLASH =          92  /* \ */;
static const int GLFW_KEY_RIGHT_BRACKET =      93  /* ] */;
static const int GLFW_KEY_GRAVE_ACCENT =       96  /* ` */;
static const int GLFW_KEY_WORLD_1 =            161 /* non-US #1 */;
static const int GLFW_KEY_WORLD_2 =            162 /* non-US #2 */;

/* Function keys */
static const int GLFW_KEY_ESCAPE =             256;
static const int GLFW_KEY_ENTER =              257;
static const int GLFW_KEY_TAB =                258;
static const int GLFW_KEY_BACKSPACE =          259;
static const int GLFW_KEY_INSERT =             260;
static const int GLFW_KEY_DELETE =             261;
static const int GLFW_KEY_RIGHT =              262;
static const int GLFW_KEY_LEFT =               263;
static const int GLFW_KEY_DOWN =               264;
static const int GLFW_KEY_UP =                 265;
static const int GLFW_KEY_PAGE_UP =            266;
static const int GLFW_KEY_PAGE_DOWN =          267;
static const int GLFW_KEY_HOME =               268;
static const int GLFW_KEY_END =                269;
static const int GLFW_KEY_CAPS_LOCK =          280;
static const int GLFW_KEY_SCROLL_LOCK =        281;
static const int GLFW_KEY_NUM_LOCK =           282;
static const int GLFW_KEY_PRINT_SCREEN =       283;
static const int GLFW_KEY_PAUSE =              284;
static const int GLFW_KEY_F1 =                 290;
static const int GLFW_KEY_F2 =                 291;
static const int GLFW_KEY_F3 =                 292;
static const int GLFW_KEY_F4 =                 293;
static const int GLFW_KEY_F5 =                 294;
static const int GLFW_KEY_F6 =                 295;
static const int GLFW_KEY_F7 =                 296;
static const int GLFW_KEY_F8 =                 297;
static const int GLFW_KEY_F9 =                 298;
static const int GLFW_KEY_F10 =                299;
static const int GLFW_KEY_F11 =                300;
static const int GLFW_KEY_F12 =                301;
static const int GLFW_KEY_F13 =                302;
static const int GLFW_KEY_F14 =                303;
static const int GLFW_KEY_F15 =                304;
static const int GLFW_KEY_F16 =                305;
static const int GLFW_KEY_F17 =                306;
static const int GLFW_KEY_F18 =                307;
static const int GLFW_KEY_F19 =                308;
static const int GLFW_KEY_F20 =                309;
static const int GLFW_KEY_F21 =                310;
static const int GLFW_KEY_F22 =                311;
static const int GLFW_KEY_F23 =                312;
static const int GLFW_KEY_F24 =                313;
static const int GLFW_KEY_F25 =                314;
static const int GLFW_KEY_KP_0 =               320;
static const int GLFW_KEY_KP_1 =               321;
static const int GLFW_KEY_KP_2 =               322;
static const int GLFW_KEY_KP_3 =               323;
static const int GLFW_KEY_KP_4 =               324;
static const int GLFW_KEY_KP_5 =               325;
static const int GLFW_KEY_KP_6 =               326;
static const int GLFW_KEY_KP_7 =               327;
static const int GLFW_KEY_KP_8 =               328;
static const int GLFW_KEY_KP_9 =               329;
static const int GLFW_KEY_KP_DECIMAL =         330;
static const int GLFW_KEY_KP_DIVIDE =          331;
static const int GLFW_KEY_KP_MULTIPLY =        332;
static const int GLFW_KEY_KP_SUBTRACT =        333;
static const int GLFW_KEY_KP_ADD =             334;
static const int GLFW_KEY_KP_ENTER =           335;
static const int GLFW_KEY_KP_EQUAL =           336;
static const int GLFW_KEY_LEFT_SHIFT =         340;
static const int GLFW_KEY_LEFT_CONTROL =       341;
static const int GLFW_KEY_LEFT_ALT =           342;
static const int GLFW_KEY_LEFT_SUPER =         343;
static const int GLFW_KEY_RIGHT_SHIFT =        344;
static const int GLFW_KEY_RIGHT_CONTROL =      345;
static const int GLFW_KEY_RIGHT_ALT =          346;
static const int GLFW_KEY_RIGHT_SUPER =        347;
static const int GLFW_KEY_MENU =               348;
static const int GLFW_KEY_LAST =               GLFW_KEY_MENU;

static const int GLFW_MOD_SHIFT =           0x0001;

static const int GLFW_MOD_CONTROL =         0x0002;

static const int GLFW_MOD_ALT =             0x0004;

static const int GLFW_MOD_SUPER =           0x0008;

static const int GLFW_MOUSE_BUTTON_1 =         0;
static const int GLFW_MOUSE_BUTTON_2 =         1;
static const int GLFW_MOUSE_BUTTON_3 =         2;
static const int GLFW_MOUSE_BUTTON_4 =         3;
static const int GLFW_MOUSE_BUTTON_5 =         4;
static const int GLFW_MOUSE_BUTTON_6 =         5;
static const int GLFW_MOUSE_BUTTON_7 =         6;
static const int GLFW_MOUSE_BUTTON_8 =         7;
static const int GLFW_MOUSE_BUTTON_LAST =      GLFW_MOUSE_BUTTON_8;
static const int GLFW_MOUSE_BUTTON_LEFT =      GLFW_MOUSE_BUTTON_1;
static const int GLFW_MOUSE_BUTTON_RIGHT =     GLFW_MOUSE_BUTTON_2;
static const int GLFW_MOUSE_BUTTON_MIDDLE =    GLFW_MOUSE_BUTTON_3;

static const int GLFW_JOYSTICK_1 =             0;
static const int GLFW_JOYSTICK_2 =             1;
static const int GLFW_JOYSTICK_3 =             2;
static const int GLFW_JOYSTICK_4 =             3;
static const int GLFW_JOYSTICK_5 =             4;
static const int GLFW_JOYSTICK_6 =             5;
static const int GLFW_JOYSTICK_7 =             6;
static const int GLFW_JOYSTICK_8 =             7;
static const int GLFW_JOYSTICK_9 =             8;
static const int GLFW_JOYSTICK_10 =            9;
static const int GLFW_JOYSTICK_11 =            10;
static const int GLFW_JOYSTICK_12 =            11;
static const int GLFW_JOYSTICK_13 =            12;
static const int GLFW_JOYSTICK_14 =            13;
static const int GLFW_JOYSTICK_15 =            14;
static const int GLFW_JOYSTICK_16 =            15;
static const int GLFW_JOYSTICK_LAST =          GLFW_JOYSTICK_16;

/*! @defgroup errors Error codes
 *  @ingroup error
 *  @{ */
/*! @brief GLFW has not been initialized.
 */
static const int GLFW_NOT_INITIALIZED =        0x00010001;
/*! @brief No context is current for this thread.
 */
static const int GLFW_NO_CURRENT_CONTEXT =     0x00010002;
/*! @brief One of the enum parameters for the function was given an invalid
 *  enum.
 */
static const int GLFW_INVALID_ENUM =           0x00010003;
/*! @brief One of the parameters for the function was given an invalid value.
 */
static const int GLFW_INVALID_VALUE =          0x00010004;
/*! @brief A memory allocation failed.
 */
static const int GLFW_OUT_OF_MEMORY =          0x00010005;
/*! @brief GLFW could not find support for the requested client API on the
 *  system.
 */
static const int GLFW_API_UNAVAILABLE =        0x00010006;
/*! @brief The requested client API version is not available.
 */
static const int GLFW_VERSION_UNAVAILABLE =    0x00010007;
/*! @brief A platform-specific error occurred that does not match any of the
 *  more specific categories.
 */
static const int GLFW_PLATFORM_ERROR =         0x00010008;
/*! @brief The clipboard did not contain data in the requested format.
 */
static const int GLFW_FORMAT_UNAVAILABLE =     0x00010009;
/*! @} */

static const int GLFW_FOCUSED =                0x00020001;
static const int GLFW_ICONIFIED =              0x00020002;
static const int GLFW_RESIZABLE =              0x00020003;
static const int GLFW_VISIBLE =                0x00020004;
static const int GLFW_DECORATED =              0x00020005;

static const int GLFW_RED_BITS =               0x00021001;
static const int GLFW_GREEN_BITS =             0x00021002;
static const int GLFW_BLUE_BITS =              0x00021003;
static const int GLFW_ALPHA_BITS =             0x00021004;
static const int GLFW_DEPTH_BITS =             0x00021005;
static const int GLFW_STENCIL_BITS =           0x00021006;
static const int GLFW_ACCUM_RED_BITS =         0x00021007;
static const int GLFW_ACCUM_GREEN_BITS =       0x00021008;
static const int GLFW_ACCUM_BLUE_BITS =        0x00021009;
static const int GLFW_ACCUM_ALPHA_BITS =       0x0002100A;
static const int GLFW_AUX_BUFFERS =            0x0002100B;
static const int GLFW_STEREO =                 0x0002100C;
static const int GLFW_SAMPLES =                0x0002100D;
static const int GLFW_SRGB_CAPABLE =           0x0002100E;
static const int GLFW_REFRESH_RATE =           0x0002100F;

static const int GLFW_CLIENT_API =             0x00022001;
static const int GLFW_CONTEXT_VERSION_MAJOR =  0x00022002;
static const int GLFW_CONTEXT_VERSION_MINOR =  0x00022003;
static const int GLFW_CONTEXT_REVISION =       0x00022004;
static const int GLFW_CONTEXT_ROBUSTNESS =     0x00022005;
static const int GLFW_OPENGL_FORWARD_COMPAT =  0x00022006;
static const int GLFW_OPENGL_DEBUG_CONTEXT =   0x00022007;
static const int GLFW_OPENGL_PROFILE =         0x00022008;

static const int GLFW_OPENGL_API =             0x00030001;
static const int GLFW_OPENGL_ES_API =          0x00030002;

static const int GLFW_NO_ROBUSTNESS =                   0;
static const int GLFW_NO_RESET_NOTIFICATION =  0x00031001;
static const int GLFW_LOSE_CONTEXT_ON_RESET =  0x00031002;

static const int GLFW_OPENGL_ANY_PROFILE =              0;
static const int GLFW_OPENGL_CORE_PROFILE =    0x00032001;
static const int GLFW_OPENGL_COMPAT_PROFILE =  0x00032002;

static const int GLFW_CURSOR =                 0x00033001;
static const int GLFW_STICKY_KEYS =            0x00033002;
static const int GLFW_STICKY_MOUSE_BUTTONS =   0x00033003;

static const int GLFW_CURSOR_NORMAL =          0x00034001;
static const int GLFW_CURSOR_HIDDEN =          0x00034002;
static const int GLFW_CURSOR_DISABLED =        0x00034003;

static const int GLFW_CONNECTED =              0x00040001;
static const int GLFW_DISCONNECTED =           0x00040002;

/*************************************************************************
 * GLFW API types
 *************************************************************************/

/*! @brief Client API function pointer type.
 *
 *  Generic function pointer used for returning client API function pointers
 *  without forcing a cast from a regular pointer.
 *
 *  @ingroup context
 */
typedef void (*GLFWglproc)(void);

/*! @brief Opaque monitor object.
 *
 *  Opaque monitor object.
 *
 *  @ingroup monitor
 */
typedef struct GLFWmonitor GLFWmonitor;

/*! @brief Opaque window object.
 *
 *  Opaque window object.
 *
 *  @ingroup window
 */
typedef struct GLFWwindow GLFWwindow;

/*! @brief The function signature for error callbacks.
 *
 *  This is the function signature for error callback functions.
 *
 *  @param[in] error An [error code](@ref errors).
 *  @param[in] description A UTF-8 encoded string describing the error.
 *
 *  @sa glfwSetErrorCallback
 *
 *  @ingroup error
 */
typedef void (* GLFWerrorfun)(int,const char*);

/*! @brief The function signature for window position callbacks.
 *
 *  This is the function signature for window position callback functions.
 *
 *  @param[in] window The window that the user moved.
 *  @param[in] xpos The new x-coordinate, in screen coordinates, of the
 *  upper-left corner of the client area of the window.
 *  @param[in] ypos The new y-coordinate, in screen coordinates, of the
 *  upper-left corner of the client area of the window.
 *
 *  @sa glfwSetWindowPosCallback
 *
 *  @ingroup window
 */
typedef void (* GLFWwindowposfun)(GLFWwindow*,int,int);

/*! @brief The function signature for window resize callbacks.
 *
 *  This is the function signature for window size callback functions.
 *
 *  @param[in] window The window that the user resized.
 *  @param[in] width The new width, in screen coordinates, of the window.
 *  @param[in] height The new height, in screen coordinates, of the window.
 *
 *  @sa glfwSetWindowSizeCallback
 *
 *  @ingroup window
 */
typedef void (* GLFWwindowsizefun)(GLFWwindow*,int,int);

/*! @brief The function signature for window close callbacks.
 *
 *  This is the function signature for window close callback functions.
 *
 *  @param[in] window The window that the user attempted to close.
 *
 *  @sa glfwSetWindowCloseCallback
 *
 *  @ingroup window
 */
typedef void (* GLFWwindowclosefun)(GLFWwindow*);

/*! @brief The function signature for window content refresh callbacks.
 *
 *  This is the function signature for window refresh callback functions.
 *
 *  @param[in] window The window whose content needs to be refreshed.
 *
 *  @sa glfwSetWindowRefreshCallback
 *
 *  @ingroup window
 */
typedef void (* GLFWwindowrefreshfun)(GLFWwindow*);

/*! @brief The function signature for window focus/defocus callbacks.
 *
 *  This is the function signature for window focus callback functions.
 *
 *  @param[in] window The window that was focused or defocused.
 *  @param[in] focused `GL_TRUE` if the window was focused, or `GL_FALSE` if
 *  it was defocused.
 *
 *  @sa glfwSetWindowFocusCallback
 *
 *  @ingroup window
 */
typedef void (* GLFWwindowfocusfun)(GLFWwindow*,int);

/*! @brief The function signature for window iconify/restore callbacks.
 *
 *  This is the function signature for window iconify/restore callback
 *  functions.
 *
 *  @param[in] window The window that was iconified or restored.
 *  @param[in] iconified `GL_TRUE` if the window was iconified, or `GL_FALSE`
 *  if it was restored.
 *
 *  @sa glfwSetWindowIconifyCallback
 *
 *  @ingroup window
 */
typedef void (* GLFWwindowiconifyfun)(GLFWwindow*,int);

/*! @brief The function signature for framebuffer resize callbacks.
 *
 *  This is the function signature for framebuffer resize callback
 *  functions.
 *
 *  @param[in] window The window whose framebuffer was resized.
 *  @param[in] width The new width, in pixels, of the framebuffer.
 *  @param[in] height The new height, in pixels, of the framebuffer.
 *
 *  @sa glfwSetFramebufferSizeCallback
 *
 *  @ingroup window
 */
typedef void (* GLFWframebuffersizefun)(GLFWwindow*,int,int);

/*! @brief The function signature for mouse button callbacks.
 *
 *  This is the function signature for mouse button callback functions.
 *
 *  @param[in] window The window that received the event.
 *  @param[in] button The [mouse button](@ref buttons) that was pressed or
 *  released.
 *  @param[in] action One of `GLFW_PRESS` or `GLFW_RELEASE`.
 *  @param[in] mods Bit field describing which [modifier keys](@ref mods) were
 *  held down.
 *
 *  @sa glfwSetMouseButtonCallback
 *
 *  @ingroup input
 */
typedef void (* GLFWmousebuttonfun)(GLFWwindow*,int,int,int);

/*! @brief The function signature for cursor position callbacks.
 *
 *  This is the function signature for cursor position callback functions.
 *
 *  @param[in] window The window that received the event.
 *  @param[in] xpos The new x-coordinate, in screen coordinates, of the cursor.
 *  @param[in] ypos The new y-coordinate, in screen coordinates, of the cursor.
 *
 *  @sa glfwSetCursorPosCallback
 *
 *  @ingroup input
 */
typedef void (* GLFWcursorposfun)(GLFWwindow*,double,double);

/*! @brief The function signature for cursor enter/leave callbacks.
 *
 *  This is the function signature for cursor enter/leave callback functions.
 *
 *  @param[in] window The window that received the event.
 *  @param[in] entered `GL_TRUE` if the cursor entered the window's client
 *  area, or `GL_FALSE` if it left it.
 *
 *  @sa glfwSetCursorEnterCallback
 *
 *  @ingroup input
 */
typedef void (* GLFWcursorenterfun)(GLFWwindow*,int);

/*! @brief The function signature for scroll callbacks.
 *
 *  This is the function signature for scroll callback functions.
 *
 *  @param[in] window The window that received the event.
 *  @param[in] xoffset The scroll offset along the x-axis.
 *  @param[in] yoffset The scroll offset along the y-axis.
 *
 *  @sa glfwSetScrollCallback
 *
 *  @ingroup input
 */
typedef void (* GLFWscrollfun)(GLFWwindow*,double,double);

/*! @brief The function signature for keyboard key callbacks.
 *
 *  This is the function signature for keyboard key callback functions.
 *
 *  @param[in] window The window that received the event.
 *  @param[in] key The [keyboard key](@ref keys) that was pressed or released.
 *  @param[in] scancode The system-specific scancode of the key.
 *  @param[in] action @ref GLFW_PRESS, @ref GLFW_RELEASE or @ref GLFW_REPEAT.
 *  @param[in] mods Bit field describing which [modifier keys](@ref mods) were
 *  held down.
 *
 *  @sa glfwSetKeyCallback
 *
 *  @ingroup input
 */
typedef void (* GLFWkeyfun)(GLFWwindow*,int,int,int,int);

/*! @brief The function signature for Unicode character callbacks.
 *
 *  This is the function signature for Unicode character callback functions.
 *
 *  @param[in] window The window that received the event.
 *  @param[in] codepoint The Unicode code point of the character.
 *
 *  @sa glfwSetCharCallback
 *
 *  @ingroup input
 */
typedef void (* GLFWcharfun)(GLFWwindow*,unsigned int);

/*! @brief The function signature for monitor configuration callbacks.
 *
 *  This is the function signature for monitor configuration callback functions.
 *
 *  @param[in] monitor The monitor that was connected or disconnected.
 *  @param[in] event One of `GLFW_CONNECTED` or `GLFW_DISCONNECTED`.
 *
 *  @sa glfwSetMonitorCallback
 *
 *  @ingroup monitor
 */
typedef void (* GLFWmonitorfun)(GLFWmonitor*,int);

/*! @brief Video mode type.
 *
 *  This describes a single video mode.
 *
 *  @ingroup monitor
 */
typedef struct GLFWvidmode
{
    /*! The width, in screen coordinates, of the video mode.
     */
    int width;
    /*! The height, in screen coordinates, of the video mode.
     */
    int height;
    /*! The bit depth of the red channel of the video mode.
     */
    int redBits;
    /*! The bit depth of the green channel of the video mode.
     */
    int greenBits;
    /*! The bit depth of the blue channel of the video mode.
     */
    int blueBits;
    /*! The refresh rate, in Hz, of the video mode.
     */
    int refreshRate;
} GLFWvidmode;

/*! @brief Gamma ramp.
 *
 *  This describes the gamma ramp for a monitor.
 *
 *  @sa glfwGetGammaRamp glfwSetGammaRamp
 *
 *  @ingroup monitor
 */
typedef struct GLFWgammaramp
{
    /*! An array of value describing the response of the red channel.
     */
    unsigned short* red;
    /*! An array of value describing the response of the green channel.
     */
    unsigned short* green;
    /*! An array of value describing the response of the blue channel.
     */
    unsigned short* blue;
    /*! The number of elements in each array.
     */
    unsigned int size;
} GLFWgammaramp;


/*************************************************************************
 * GLFW API functions
 *************************************************************************/

/*! @brief Initializes the GLFW library.
 *
 *  This function initializes the GLFW library.  Before most GLFW functions can
 *  be used, GLFW must be initialized, and before a program terminates GLFW
 *  should be terminated in order to free any resources allocated during or
 *  after initialization.
 *
 *  If this function fails, it calls @ref glfwTerminate before returning.  If it
 *  succeeds, you should call @ref glfwTerminate before the program exits.
 *
 *  Additional calls to this function after successful initialization but before
 *  termination will succeed but will do nothing.
 *
 *  @return `GL_TRUE` if successful, or `GL_FALSE` if an error occurred.
 *
 *  @par New in GLFW 3
 *  This function no longer registers @ref glfwTerminate with `atexit`.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @note **OS X:** This function will change the current directory of the
 *  application to the `Contents/Resources` subdirectory of the application's
 *  bundle, if present.
 *
 *  @sa glfwTerminate
 *
 *  @ingroup init
 */
int glfwInit(void);

/*! @brief Terminates the GLFW library.
 *
 *  This function destroys all remaining windows, frees any allocated resources
 *  and sets the library to an uninitialized state.  Once this is called, you
 *  must again call @ref glfwInit successfully before you will be able to use
 *  most GLFW functions.
 *
 *  If GLFW has been successfully initialized, this function should be called
 *  before the program exits.  If initialization fails, there is no need to call
 *  this function, as it is called by @ref glfwInit before it returns failure.
 *
 *  @remarks This function may be called before @ref glfwInit.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @warning No window's context may be current on another thread when this
 *  function is called.
 *
 *  @sa glfwInit
 *
 *  @ingroup init
 */
void glfwTerminate(void);

/*! @brief Retrieves the version of the GLFW library.
 *
 *  This function retrieves the major, minor and revision numbers of the GLFW
 *  library.  It is intended for when you are using GLFW as a shared library and
 *  want to ensure that you are using the minimum required version.
 *
 *  @param[out] major Where to store the major version number, or `NULL`.
 *  @param[out] minor Where to store the minor version number, or `NULL`.
 *  @param[out] rev Where to store the revision number, or `NULL`.
 *
 *  @remarks This function may be called before @ref glfwInit.
 *
 *  @remarks This function may be called from any thread.
 *
 *  @sa glfwGetVersionString
 *
 *  @ingroup init
 */
void glfwGetVersion(int* major, int* minor, int* rev);

/*! @brief Returns a string describing the compile-time configuration.
 *
 *  This function returns a static string generated at compile-time according to
 *  which configuration macros were defined.  This is intended for use when
 *  submitting bug reports, to allow developers to see which code paths are
 *  enabled in a binary.
 *
 *  The format of the string is as follows:
 *  - The version of GLFW
 *  - The name of the window system API
 *  - The name of the context creation API
 *  - Any additional options or APIs
 *
 *  For example, when compiling GLFW 3.0 with MinGW using the Win32 and WGL
 *  back ends, the version string may look something like this:
 *
 *      3.0.0 Win32 WGL MinGW
 *
 *  @return The GLFW version string.
 *
 *  @remarks This function may be called before @ref glfwInit.
 *
 *  @remarks This function may be called from any thread.
 *
 *  @sa glfwGetVersion
 *
 *  @ingroup init
 */
const char* glfwGetVersionString(void);

/*! @brief Sets the error callback.
 *
 *  This function sets the error callback, which is called with an error code
 *  and a human-readable description each time a GLFW error occurs.
 *
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @remarks This function may be called before @ref glfwInit.
 *
 *  @note The error callback is called by the thread where the error was
 *  generated.  If you are using GLFW from multiple threads, your error callback
 *  needs to be written accordingly.
 *
 *  @note Because the description string provided to the callback may have been
 *  generated specifically for that error, it is not guaranteed to be valid
 *  after the callback has returned.  If you wish to use it after that, you need
 *  to make your own copy of it before returning.
 *
 *  @ingroup error
 */
GLFWerrorfun glfwSetErrorCallback(GLFWerrorfun cbfun);

/*! @brief Returns the currently connected monitors.
 *
 *  This function returns an array of handles for all currently connected
 *  monitors.
 *
 *  @param[out] count Where to store the size of the returned array.  This is
 *  set to zero if an error occurred.
 *  @return An array of monitor handles, or `NULL` if an error occurred.
 *
 *  @note The returned array is allocated and freed by GLFW.  You should not
 *  free it yourself.
 *
 *  @note The returned array is valid only until the monitor configuration
 *  changes.  See @ref glfwSetMonitorCallback to receive notifications of
 *  configuration changes.
 *
 *  @sa glfwGetPrimaryMonitor
 *
 *  @ingroup monitor
 */
GLFWmonitor** glfwGetMonitors(int* count);

/*! @brief Returns the primary monitor.
 *
 *  This function returns the primary monitor.  This is usually the monitor
 *  where elements like the Windows task bar or the OS X menu bar is located.
 *
 *  @return The primary monitor, or `NULL` if an error occurred.
 *
 *  @sa glfwGetMonitors
 *
 *  @ingroup monitor
 */
GLFWmonitor* glfwGetPrimaryMonitor(void);

/*! @brief Returns the position of the monitor's viewport on the virtual screen.
 *
 *  This function returns the position, in screen coordinates, of the upper-left
 *  corner of the specified monitor.
 *
 *  @param[in] monitor The monitor to query.
 *  @param[out] xpos Where to store the monitor x-coordinate, or `NULL`.
 *  @param[out] ypos Where to store the monitor y-coordinate, or `NULL`.
 *
 *  @ingroup monitor
 */
void glfwGetMonitorPos(GLFWmonitor* monitor, int* xpos, int* ypos);

/*! @brief Returns the physical size of the monitor.
 *
 *  This function returns the size, in millimetres, of the display area of the
 *  specified monitor.
 *
 *  @param[in] monitor The monitor to query.
 *  @param[out] width Where to store the width, in mm, of the monitor's display
 *  area, or `NULL`.
 *  @param[out] height Where to store the height, in mm, of the monitor's
 *  display area, or `NULL`.
 *
 *  @note Some operating systems do not provide accurate information, either
 *  because the monitor's EDID data is incorrect, or because the driver does not
 *  report it accurately.
 *
 *  @ingroup monitor
 */
void glfwGetMonitorPhysicalSize(GLFWmonitor* monitor, int* width, int* height);

/*! @brief Returns the name of the specified monitor.
 *
 *  This function returns a human-readable name, encoded as UTF-8, of the
 *  specified monitor.
 *
 *  @param[in] monitor The monitor to query.
 *  @return The UTF-8 encoded name of the monitor, or `NULL` if an error
 *  occurred.
 *
 *  @note The returned string is allocated and freed by GLFW.  You should not
 *  free it yourself.
 *
 *  @ingroup monitor
 */
const char* glfwGetMonitorName(GLFWmonitor* monitor);

/*! @brief Sets the monitor configuration callback.
 *
 *  This function sets the monitor configuration callback, or removes the
 *  currently set callback.  This is called when a monitor is connected to or
 *  disconnected from the system.
 *
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @bug **X11:** This callback is not yet called on monitor configuration
 *  changes.
 *
 *  @ingroup monitor
 */
GLFWmonitorfun glfwSetMonitorCallback(GLFWmonitorfun cbfun);

/*! @brief Returns the available video modes for the specified monitor.
 *
 *  This function returns an array of all video modes supported by the specified
 *  monitor.  The returned array is sorted in ascending order, first by color
 *  bit depth (the sum of all channel depths) and then by resolution area (the
 *  product of width and height).
 *
 *  @param[in] monitor The monitor to query.
 *  @param[out] count Where to store the number of video modes in the returned
 *  array.  This is set to zero if an error occurred.
 *  @return An array of video modes, or `NULL` if an error occurred.
 *
 *  @note The returned array is allocated and freed by GLFW.  You should not
 *  free it yourself.
 *
 *  @note The returned array is valid only until this function is called again
 *  for the specified monitor.
 *
 *  @sa glfwGetVideoMode
 *
 *  @ingroup monitor
 */
const GLFWvidmode* glfwGetVideoModes(GLFWmonitor* monitor, int* count);

/*! @brief Returns the current mode of the specified monitor.
 *
 *  This function returns the current video mode of the specified monitor.  If
 *  you are using a full screen window, the return value will therefore depend
 *  on whether it is focused.
 *
 *  @param[in] monitor The monitor to query.
 *  @return The current mode of the monitor, or `NULL` if an error occurred.
 *
 *  @note The returned struct is allocated and freed by GLFW.  You should not
 *  free it yourself.
 *
 *  @sa glfwGetVideoModes
 *
 *  @ingroup monitor
 */
const GLFWvidmode* glfwGetVideoMode(GLFWmonitor* monitor);

/*! @brief Generates a gamma ramp and sets it for the specified monitor.
 *
 *  This function generates a 256-element gamma ramp from the specified exponent
 *  and then calls @ref glfwSetGammaRamp with it.
 *
 *  @param[in] monitor The monitor whose gamma ramp to set.
 *  @param[in] gamma The desired exponent.
 *
 *  @ingroup monitor
 */
void glfwSetGamma(GLFWmonitor* monitor, float gamma);

/*! @brief Retrieves the current gamma ramp for the specified monitor.
 *
 *  This function retrieves the current gamma ramp of the specified monitor.
 *
 *  @param[in] monitor The monitor to query.
 *  @return The current gamma ramp, or `NULL` if an error occurred.
 *
 *  @note The value arrays of the returned ramp are allocated and freed by GLFW.
 *  You should not free them yourself.
 *
 *  @ingroup monitor
 */
const GLFWgammaramp* glfwGetGammaRamp(GLFWmonitor* monitor);

/*! @brief Sets the current gamma ramp for the specified monitor.
 *
 *  This function sets the current gamma ramp for the specified monitor.
 *
 *  @param[in] monitor The monitor whose gamma ramp to set.
 *  @param[in] ramp The gamma ramp to use.
 *
 *  @note Gamma ramp sizes other than 256 are not supported by all hardware.
 *
 *  @ingroup monitor
 */
void glfwSetGammaRamp(GLFWmonitor* monitor, const GLFWgammaramp* ramp);

/*! @brief Resets all window hints to their default values.
 *
 *  This function resets all window hints to their
 *  [default values](@ref window_hints_values).
 *
 *  @note This function may only be called from the main thread.
 *
 *  @sa glfwWindowHint
 *
 *  @ingroup window
 */
void glfwDefaultWindowHints(void);

/*! @brief Sets the specified window hint to the desired value.
 *
 *  This function sets hints for the next call to @ref glfwCreateWindow.  The
 *  hints, once set, retain their values until changed by a call to @ref
 *  glfwWindowHint or @ref glfwDefaultWindowHints, or until the library is
 *  terminated with @ref glfwTerminate.
 *
 *  @param[in] target The [window hint](@ref window_hints) to set.
 *  @param[in] hint The new value of the window hint.
 *
 *  @par New in GLFW 3
 *  Hints are no longer reset to their default values on window creation.  To
 *  set default hint values, use @ref glfwDefaultWindowHints.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @sa glfwDefaultWindowHints
 *
 *  @ingroup window
 */
void glfwWindowHint(int target, int hint);

/*! @brief Creates a window and its associated context.
 *
 *  This function creates a window and its associated context.  Most of the
 *  options controlling how the window and its context should be created are
 *  specified through @ref glfwWindowHint.
 *
 *  Successful creation does not change which context is current.  Before you
 *  can use the newly created context, you need to make it current using @ref
 *  glfwMakeContextCurrent.
 *
 *  Note that the created window and context may differ from what you requested,
 *  as not all parameters and hints are
 *  [hard constraints](@ref window_hints_hard).  This includes the size of the
 *  window, especially for full screen windows.  To retrieve the actual
 *  attributes of the created window and context, use queries like @ref
 *  glfwGetWindowAttrib and @ref glfwGetWindowSize.
 *
 *  To create a full screen window, you need to specify the monitor to use.  If
 *  no monitor is specified, windowed mode will be used.  Unless you have a way
 *  for the user to choose a specific monitor, it is recommended that you pick
 *  the primary monitor.  For more information on how to retrieve monitors, see
 *  @ref monitor_monitors.
 *
 *  To create the window at a specific position, make it initially invisible
 *  using the `GLFW_VISIBLE` window hint, set its position and then show it.
 *
 *  If a full screen window is active, the screensaver is prohibited from
 *  starting.
 *
 *  @param[in] width The desired width, in screen coordinates, of the window.
 *  This must be greater than zero.
 *  @param[in] height The desired height, in screen coordinates, of the window.
 *  This must be greater than zero.
 *  @param[in] title The initial, UTF-8 encoded window title.
 *  @param[in] monitor The monitor to use for full screen mode, or `NULL` to use
 *  windowed mode.
 *  @param[in] share The window whose context to share resources with, or `NULL`
 *  to not share resources.
 *  @return The handle of the created window, or `NULL` if an error occurred.
 *
 *  @remarks **Windows:** Window creation will fail if the Microsoft GDI
 *  software OpenGL implementation is the only one available.
 *
 *  @remarks **Windows:** If the executable has an icon resource named
 *  `GLFW_ICON,` it will be set as the icon for the window.  If no such icon is
 *  present, the `IDI_WINLOGO` icon will be used instead.
 *
 *  @remarks **OS X:** The GLFW window has no icon, as it is not a document
 *  window, but the dock icon will be the same as the application bundle's icon.
 *  Also, the first time a window is opened the menu bar is populated with
 *  common commands like Hide, Quit and About.  The (minimal) about dialog uses
 *  information from the application's bundle.  For more information on bundles,
 *  see the Bundle Programming Guide provided by Apple.
 *
 *  @remarks **X11:** There is no mechanism for setting the window icon yet.
 *
 *  @remarks The swap interval is not set during window creation, but is left at
 *  the default value for that platform.  For more information, see @ref
 *  glfwSwapInterval.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @sa glfwDestroyWindow
 *
 *  @ingroup window
 */
GLFWwindow* glfwCreateWindow(int width, int height, const char* title, GLFWmonitor* monitor, GLFWwindow* share);

/*! @brief Destroys the specified window and its context.
 *
 *  This function destroys the specified window and its context.  On calling
 *  this function, no further callbacks will be called for that window.
 *
 *  @param[in] window The window to destroy.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @note This function may not be called from a callback.
 *
 *  @note If the window's context is current on the main thread, it is
 *  detached before being destroyed.
 *
 *  @warning The window's context must not be current on any other thread.
 *
 *  @sa glfwCreateWindow
 *
 *  @ingroup window
 */
void glfwDestroyWindow(GLFWwindow* window);

/*! @brief Checks the close flag of the specified window.
 *
 *  This function returns the value of the close flag of the specified window.
 *
 *  @param[in] window The window to query.
 *  @return The value of the close flag.
 *
 *  @remarks This function may be called from secondary threads.
 *
 *  @ingroup window
 */
int glfwWindowShouldClose(GLFWwindow* window);

/*! @brief Sets the close flag of the specified window.
 *
 *  This function sets the value of the close flag of the specified window.
 *  This can be used to override the user's attempt to close the window, or
 *  to signal that it should be closed.
 *
 *  @param[in] window The window whose flag to change.
 *  @param[in] value The new value.
 *
 *  @remarks This function may be called from secondary threads.
 *
 *  @ingroup window
 */
void glfwSetWindowShouldClose(GLFWwindow* window, int value);

/*! @brief Sets the title of the specified window.
 *
 *  This function sets the window title, encoded as UTF-8, of the specified
 *  window.
 *
 *  @param[in] window The window whose title to change.
 *  @param[in] title The UTF-8 encoded window title.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @ingroup window
 */
void glfwSetWindowTitle(GLFWwindow* window, const char* title);

/*! @brief Retrieves the position of the client area of the specified window.
 *
 *  This function retrieves the position, in screen coordinates, of the
 *  upper-left corner of the client area of the specified window.
 *
 *  @param[in] window The window to query.
 *  @param[out] xpos Where to store the x-coordinate of the upper-left corner of
 *  the client area, or `NULL`.
 *  @param[out] ypos Where to store the y-coordinate of the upper-left corner of
 *  the client area, or `NULL`.
 *
 *  @sa glfwSetWindowPos
 *
 *  @ingroup window
 */
void glfwGetWindowPos(GLFWwindow* window, int* xpos, int* ypos);

/*! @brief Sets the position of the client area of the specified window.
 *
 *  This function sets the position, in screen coordinates, of the upper-left
 *  corner of the client area of the window.
 *
 *  If the specified window is a full screen window, this function does nothing.
 *
 *  If you wish to set an initial window position you should create a hidden
 *  window (using @ref glfwWindowHint and `GLFW_VISIBLE`), set its position and
 *  then show it.
 *
 *  @param[in] window The window to query.
 *  @param[in] xpos The x-coordinate of the upper-left corner of the client area.
 *  @param[in] ypos The y-coordinate of the upper-left corner of the client area.
 *
 *  @note It is very rarely a good idea to move an already visible window, as it
 *  will confuse and annoy the user.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @note The window manager may put limits on what positions are allowed.
 *
 *  @sa glfwGetWindowPos
 *
 *  @ingroup window
 */
void glfwSetWindowPos(GLFWwindow* window, int xpos, int ypos);

/*! @brief Retrieves the size of the client area of the specified window.
 *
 *  This function retrieves the size, in screen coordinates, of the client area
 *  of the specified window.  If you wish to retrieve the size of the
 *  framebuffer in pixels, see @ref glfwGetFramebufferSize.
 *
 *  @param[in] window The window whose size to retrieve.
 *  @param[out] width Where to store the width, in screen coordinates, of the
 *  client area, or `NULL`.
 *  @param[out] height Where to store the height, in screen coordinates, of the
 *  client area, or `NULL`.
 *
 *  @sa glfwSetWindowSize
 *
 *  @ingroup window
 */
void glfwGetWindowSize(GLFWwindow* window, int* width, int* height);

/*! @brief Sets the size of the client area of the specified window.
 *
 *  This function sets the size, in screen coordinates, of the client area of
 *  the specified window.
 *
 *  For full screen windows, this function selects and switches to the resolution
 *  closest to the specified size, without affecting the window's context.  As
 *  the context is unaffected, the bit depths of the framebuffer remain
 *  unchanged.
 *
 *  @param[in] window The window to resize.
 *  @param[in] width The desired width of the specified window.
 *  @param[in] height The desired height of the specified window.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @note The window manager may put limits on what window sizes are allowed.
 *
 *  @sa glfwGetWindowSize
 *
 *  @ingroup window
 */
void glfwSetWindowSize(GLFWwindow* window, int width, int height);

/*! @brief Retrieves the size of the framebuffer of the specified window.
 *
 *  This function retrieves the size, in pixels, of the framebuffer of the
 *  specified window.  If you wish to retrieve the size of the window in screen
 *  coordinates, see @ref glfwGetWindowSize.
 *
 *  @param[in] window The window whose framebuffer to query.
 *  @param[out] width Where to store the width, in pixels, of the framebuffer,
 *  or `NULL`.
 *  @param[out] height Where to store the height, in pixels, of the framebuffer,
 *  or `NULL`.
 *
 *  @sa glfwSetFramebufferSizeCallback
 *
 *  @ingroup window
 */
void glfwGetFramebufferSize(GLFWwindow* window, int* width, int* height);

/*! @brief Iconifies the specified window.
 *
 *  This function iconifies/minimizes the specified window, if it was previously
 *  restored.  If it is a full screen window, the original monitor resolution is
 *  restored until the window is restored.  If the window is already iconified,
 *  this function does nothing.
 *
 *  @param[in] window The window to iconify.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @sa glfwRestoreWindow
 *
 *  @ingroup window
 */
void glfwIconifyWindow(GLFWwindow* window);

/*! @brief Restores the specified window.
 *
 *  This function restores the specified window, if it was previously
 *  iconified/minimized.  If it is a full screen window, the resolution chosen
 *  for the window is restored on the selected monitor.  If the window is
 *  already restored, this function does nothing.
 *
 *  @param[in] window The window to restore.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @sa glfwIconifyWindow
 *
 *  @ingroup window
 */
void glfwRestoreWindow(GLFWwindow* window);

/*! @brief Makes the specified window visible.
 *
 *  This function makes the specified window visible, if it was previously
 *  hidden.  If the window is already visible or is in full screen mode, this
 *  function does nothing.
 *
 *  @param[in] window The window to make visible.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @sa glfwHideWindow
 *
 *  @ingroup window
 */
void glfwShowWindow(GLFWwindow* window);

/*! @brief Hides the specified window.
 *
 *  This function hides the specified window, if it was previously visible.  If
 *  the window is already hidden or is in full screen mode, this function does
 *  nothing.
 *
 *  @param[in] window The window to hide.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @sa glfwShowWindow
 *
 *  @ingroup window
 */
void glfwHideWindow(GLFWwindow* window);

/*! @brief Returns the monitor that the window uses for full screen mode.
 *
 *  This function returns the handle of the monitor that the specified window is
 *  in full screen on.
 *
 *  @param[in] window The window to query.
 *  @return The monitor, or `NULL` if the window is in windowed mode.
 *
 *  @ingroup window
 */
GLFWmonitor* glfwGetWindowMonitor(GLFWwindow* window);

/*! @brief Returns an attribute of the specified window.
 *
 *  This function returns an attribute of the specified window.  There are many
 *  attributes, some related to the window and others to its context.
 *
 *  @param[in] window The window to query.
 *  @param[in] attrib The [window attribute](@ref window_attribs) whose value to
 *  return.
 *  @return The value of the attribute, or zero if an error occurred.
 *
 *  @ingroup window
 */
int glfwGetWindowAttrib(GLFWwindow* window, int attrib);

/*! @brief Sets the user pointer of the specified window.
 *
 *  This function sets the user-defined pointer of the specified window.  The
 *  current value is retained until the window is destroyed.  The initial value
 *  is `NULL`.
 *
 *  @param[in] window The window whose pointer to set.
 *  @param[in] pointer The new value.
 *
 *  @sa glfwGetWindowUserPointer
 *
 *  @ingroup window
 */
void glfwSetWindowUserPointer(GLFWwindow* window, void* pointer);

/*! @brief Returns the user pointer of the specified window.
 *
 *  This function returns the current value of the user-defined pointer of the
 *  specified window.  The initial value is `NULL`.
 *
 *  @param[in] window The window whose pointer to return.
 *
 *  @sa glfwSetWindowUserPointer
 *
 *  @ingroup window
 */
void* glfwGetWindowUserPointer(GLFWwindow* window);

/*! @brief Sets the position callback for the specified window.
 *
 *  This function sets the position callback of the specified window, which is
 *  called when the window is moved.  The callback is provided with the screen
 *  position of the upper-left corner of the client area of the window.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup window
 */
GLFWwindowposfun glfwSetWindowPosCallback(GLFWwindow* window, GLFWwindowposfun cbfun);

/*! @brief Sets the size callback for the specified window.
 *
 *  This function sets the size callback of the specified window, which is
 *  called when the window is resized.  The callback is provided with the size,
 *  in screen coordinates, of the client area of the window.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup window
 */
GLFWwindowsizefun glfwSetWindowSizeCallback(GLFWwindow* window, GLFWwindowsizefun cbfun);

/*! @brief Sets the close callback for the specified window.
 *
 *  This function sets the close callback of the specified window, which is
 *  called when the user attempts to close the window, for example by clicking
 *  the close widget in the title bar.
 *
 *  The close flag is set before this callback is called, but you can modify it
 *  at any time with @ref glfwSetWindowShouldClose.
 *
 *  The close callback is not triggered by @ref glfwDestroyWindow.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @par New in GLFW 3
 *  The close callback no longer returns a value.
 *
 *  @remarks **OS X:** Selecting Quit from the application menu will
 *  trigger the close callback for all windows.
 *
 *  @ingroup window
 */
GLFWwindowclosefun glfwSetWindowCloseCallback(GLFWwindow* window, GLFWwindowclosefun cbfun);

/*! @brief Sets the refresh callback for the specified window.
 *
 *  This function sets the refresh callback of the specified window, which is
 *  called when the client area of the window needs to be redrawn, for example
 *  if the window has been exposed after having been covered by another window.
 *
 *  On compositing window systems such as Aero, Compiz or Aqua, where the window
 *  contents are saved off-screen, this callback may be called only very
 *  infrequently or never at all.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @note On compositing window systems such as Aero, Compiz or Aqua, where the
 *  window contents are saved off-screen, this callback may be called only very
 *  infrequently or never at all.
 *
 *  @ingroup window
 */
GLFWwindowrefreshfun glfwSetWindowRefreshCallback(GLFWwindow* window, GLFWwindowrefreshfun cbfun);

/*! @brief Sets the focus callback for the specified window.
 *
 *  This function sets the focus callback of the specified window, which is
 *  called when the window gains or loses focus.
 *
 *  After the focus callback is called for a window that lost focus, synthetic
 *  key and mouse button release events will be generated for all such that had
 *  been pressed.  For more information, see @ref glfwSetKeyCallback and @ref
 *  glfwSetMouseButtonCallback.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup window
 */
GLFWwindowfocusfun glfwSetWindowFocusCallback(GLFWwindow* window, GLFWwindowfocusfun cbfun);

/*! @brief Sets the iconify callback for the specified window.
 *
 *  This function sets the iconification callback of the specified window, which
 *  is called when the window is iconified or restored.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup window
 */
GLFWwindowiconifyfun glfwSetWindowIconifyCallback(GLFWwindow* window, GLFWwindowiconifyfun cbfun);

/*! @brief Sets the framebuffer resize callback for the specified window.
 *
 *  This function sets the framebuffer resize callback of the specified window,
 *  which is called when the framebuffer of the specified window is resized.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup window
 */
GLFWframebuffersizefun glfwSetFramebufferSizeCallback(GLFWwindow* window, GLFWframebuffersizefun cbfun);

/*! @brief Processes all pending events.
 *
 *  This function processes only those events that have already been received
 *  and then returns immediately.  Processing events will cause the window and
 *  input callbacks associated with those events to be called.
 *
 *  This function is not required for joystick input to work.
 *
 *  @par New in GLFW 3
 *  This function is no longer called by @ref glfwSwapBuffers.  You need to call
 *  it or @ref glfwWaitEvents yourself.
 *
 *  @remarks On some platforms, a window move, resize or menu operation will
 *  cause event processing to block.  This is due to how event processing is
 *  designed on those platforms.  You can use the
 *  [window refresh callback](@ref GLFWwindowrefreshfun) to redraw the contents
 *  of your window when necessary during the operation.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @note This function may not be called from a callback.
 *
 *  @note On some platforms, certain callbacks may be called outside of a call
 *  to one of the event processing functions.
 *
 *  @sa glfwWaitEvents
 *
 *  @ingroup window
 */
void glfwPollEvents(void);

/*! @brief Waits until events are pending and processes them.
 *
 *  This function puts the calling thread to sleep until at least one event has
 *  been received.  Once one or more events have been received, it behaves as if
 *  @ref glfwPollEvents was called, i.e. the events are processed and the
 *  function then returns immediately.  Processing events will cause the window
 *  and input callbacks associated with those events to be called.
 *
 *  Since not all events are associated with callbacks, this function may return
 *  without a callback having been called even if you are monitoring all
 *  callbacks.
 *
 *  This function is not required for joystick input to work.
 *
 *  @remarks On some platforms, a window move, resize or menu operation will
 *  cause event processing to block.  This is due to how event processing is
 *  designed on those platforms.  You can use the
 *  [window refresh callback](@ref GLFWwindowrefreshfun) to redraw the contents
 *  of your window when necessary during the operation.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @note This function may not be called from a callback.
 *
 *  @note On some platforms, certain callbacks may be called outside of a call
 *  to one of the event processing functions.
 *
 *  @sa glfwPollEvents
 *
 *  @ingroup window
 */
void glfwWaitEvents(void);

/*! @brief Returns the value of an input option for the specified window.
 *
 *  @param[in] window The window to query.
 *  @param[in] mode One of `GLFW_CURSOR`, `GLFW_STICKY_KEYS` or
 *  `GLFW_STICKY_MOUSE_BUTTONS`.
 *
 *  @sa glfwSetInputMode
 *
 *  @ingroup input
 */
int glfwGetInputMode(GLFWwindow* window, int mode);

/*! @brief Sets an input option for the specified window.
 *  @param[in] window The window whose input mode to set.
 *  @param[in] mode One of `GLFW_CURSOR`, `GLFW_STICKY_KEYS` or
 *  `GLFW_STICKY_MOUSE_BUTTONS`.
 *  @param[in] value The new value of the specified input mode.
 *
 *  If `mode` is `GLFW_CURSOR`, the value must be one of the supported input
 *  modes:
 *  - `GLFW_CURSOR_NORMAL` makes the cursor visible and behaving normally.
 *  - `GLFW_CURSOR_HIDDEN` makes the cursor invisible when it is over the client
 *    area of the window but does not restrict the cursor from leaving.  This is
 *    useful if you wish to render your own cursor or have no visible cursor at
 *    all.
 *  - `GLFW_CURSOR_DISABLED` hides and grabs the cursor, providing virtual
 *    and unlimited cursor movement.  This is useful for implementing for
 *    example 3D camera controls.
 *
 *  If `mode` is `GLFW_STICKY_KEYS`, the value must be either `GL_TRUE` to
 *  enable sticky keys, or `GL_FALSE` to disable it.  If sticky keys are
 *  enabled, a key press will ensure that @ref glfwGetKey returns @ref
 *  GLFW_PRESS the next time it is called even if the key had been released
 *  before the call.  This is useful when you are only interested in whether
 *  keys have been pressed but not when or in which order.
 *
 *  If `mode` is `GLFW_STICKY_MOUSE_BUTTONS`, the value must be either `GL_TRUE`
 *  to enable sticky mouse buttons, or `GL_FALSE` to disable it.  If sticky
 *  mouse buttons are enabled, a mouse button press will ensure that @ref
 *  glfwGetMouseButton returns @ref GLFW_PRESS the next time it is called even
 *  if the mouse button had been released before the call.  This is useful when
 *  you are only interested in whether mouse buttons have been pressed but not
 *  when or in which order.
 *
 *  @sa glfwGetInputMode
 *
 *  @ingroup input
 */
void glfwSetInputMode(GLFWwindow* window, int mode, int value);

/*! @brief Returns the last reported state of a keyboard key for the specified
 *  window.
 *
 *  This function returns the last state reported for the specified key to the
 *  specified window.  The returned state is one of `GLFW_PRESS` or
 *  `GLFW_RELEASE`.  The higher-level state `GLFW_REPEAT` is only reported to
 *  the key callback.
 *
 *  If the `GLFW_STICKY_KEYS` input mode is enabled, this function returns
 *  `GLFW_PRESS` the first time you call this function after a key has been
 *  pressed, even if the key has already been released.
 *
 *  The key functions deal with physical keys, with [key tokens](@ref keys)
 *  named after their use on the standard US keyboard layout.  If you want to
 *  input text, use the Unicode character callback instead.
 *
 *  @param[in] window The desired window.
 *  @param[in] key The desired [keyboard key](@ref keys).
 *  @return One of `GLFW_PRESS` or `GLFW_RELEASE`.
 *
 *  @note `GLFW_KEY_UNKNOWN` is not a valid key for this function.
 *
 *  @ingroup input
 */
int glfwGetKey(GLFWwindow* window, int key);

/*! @brief Returns the last reported state of a mouse button for the specified
 *  window.
 *
 *  This function returns the last state reported for the specified mouse button
 *  to the specified window.
 *
 *  If the `GLFW_STICKY_MOUSE_BUTTONS` input mode is enabled, this function
 *  returns `GLFW_PRESS` the first time you call this function after a mouse
 *  button has been pressed, even if the mouse button has already been released.
 *
 *  @param[in] window The desired window.
 *  @param[in] button The desired [mouse button](@ref buttons).
 *  @return One of `GLFW_PRESS` or `GLFW_RELEASE`.
 *
 *  @ingroup input
 */
int glfwGetMouseButton(GLFWwindow* window, int button);

/*! @brief Retrieves the last reported cursor position, relative to the client
 *  area of the window.
 *
 *  This function returns the last reported position of the cursor, in screen
 *  coordinates, relative to the upper-left corner of the client area of the
 *  specified window.
 *
 *  If the cursor is disabled (with `GLFW_CURSOR_DISABLED`) then the cursor
 *  position is unbounded and limited only by the minimum and maximum values of
 *  a `double`.
 *
 *  The coordinate can be converted to their integer equivalents with the
 *  `floor` function.  Casting directly to an integer type works for positive
 *  coordinates, but fails for negative ones.
 *
 *  @param[in] window The desired window.
 *  @param[out] xpos Where to store the cursor x-coordinate, relative to the
 *  left edge of the client area, or `NULL`.
 *  @param[out] ypos Where to store the cursor y-coordinate, relative to the to
 *  top edge of the client area, or `NULL`.
 *
 *  @sa glfwSetCursorPos
 *
 *  @ingroup input
 */
void glfwGetCursorPos(GLFWwindow* window, double* xpos, double* ypos);

/*! @brief Sets the position of the cursor, relative to the client area of the
 *  window.
 *
 *  This function sets the position, in screen coordinates, of the cursor
 *  relative to the upper-left corner of the client area of the specified
 *  window.  The window must be focused.  If the window does not have focus when
 *  this function is called, it fails silently.
 *
 *  If the cursor is disabled (with `GLFW_CURSOR_DISABLED`) then the cursor
 *  position is unbounded and limited only by the minimum and maximum values of
 *  a `double`.
 *
 *  @param[in] window The desired window.
 *  @param[in] xpos The desired x-coordinate, relative to the left edge of the
 *  client area.
 *  @param[in] ypos The desired y-coordinate, relative to the top edge of the
 *  client area.
 *
 *  @sa glfwGetCursorPos
 *
 *  @ingroup input
 */
void glfwSetCursorPos(GLFWwindow* window, double xpos, double ypos);

/*! @brief Sets the key callback.
 *
 *  This function sets the key callback of the specific window, which is called
 *  when a key is pressed, repeated or released.
 *
 *  The key functions deal with physical keys, with layout independent
 *  [key tokens](@ref keys) named after their values in the standard US keyboard
 *  layout.  If you want to input text, use the
 *  [character callback](@ref glfwSetCharCallback) instead.
 *
 *  When a window loses focus, it will generate synthetic key release events
 *  for all pressed keys.  You can tell these events from user-generated events
 *  by the fact that the synthetic ones are generated after the window has lost
 *  focus, i.e. `GLFW_FOCUSED` will be false and the focus callback will have
 *  already been called.
 *
 *  The scancode of a key is specific to that platform or sometimes even to that
 *  machine.  Scancodes are intended to allow users to bind keys that don't have
 *  a GLFW key token.  Such keys have `key` set to `GLFW_KEY_UNKNOWN`, their
 *  state is not saved and so it cannot be retrieved with @ref glfwGetKey.
 *
 *  Sometimes GLFW needs to generate synthetic key events, in which case the
 *  scancode may be zero.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new key callback, or `NULL` to remove the currently
 *  set callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup input
 */
GLFWkeyfun glfwSetKeyCallback(GLFWwindow* window, GLFWkeyfun cbfun);

/*! @brief Sets the Unicode character callback.
 *
 *  This function sets the character callback of the specific window, which is
 *  called when a Unicode character is input.
 *
 *  The character callback is intended for text input.  If you want to know
 *  whether a specific key was pressed or released, use the
 *  [key callback](@ref glfwSetKeyCallback) instead.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup input
 */
GLFWcharfun glfwSetCharCallback(GLFWwindow* window, GLFWcharfun cbfun);

/*! @brief Sets the mouse button callback.
 *
 *  This function sets the mouse button callback of the specified window, which
 *  is called when a mouse button is pressed or released.
 *
 *  When a window loses focus, it will generate synthetic mouse button release
 *  events for all pressed mouse buttons.  You can tell these events from
 *  user-generated events by the fact that the synthetic ones are generated
 *  after the window has lost focus, i.e. `GLFW_FOCUSED` will be false and the
 *  focus callback will have already been called.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup input
 */
GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow* window, GLFWmousebuttonfun cbfun);

/*! @brief Sets the cursor position callback.
 *
 *  This function sets the cursor position callback of the specified window,
 *  which is called when the cursor is moved.  The callback is provided with the
 *  position, in screen coordinates, relative to the upper-left corner of the
 *  client area of the window.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup input
 */
GLFWcursorposfun glfwSetCursorPosCallback(GLFWwindow* window, GLFWcursorposfun cbfun);

/*! @brief Sets the cursor enter/exit callback.
 *
 *  This function sets the cursor boundary crossing callback of the specified
 *  window, which is called when the cursor enters or leaves the client area of
 *  the window.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new callback, or `NULL` to remove the currently set
 *  callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup input
 */
GLFWcursorenterfun glfwSetCursorEnterCallback(GLFWwindow* window, GLFWcursorenterfun cbfun);

/*! @brief Sets the scroll callback.
 *
 *  This function sets the scroll callback of the specified window, which is
 *  called when a scrolling device is used, such as a mouse wheel or scrolling
 *  area of a touchpad.
 *
 *  The scroll callback receives all scrolling input, like that from a mouse
 *  wheel or a touchpad scrolling area.
 *
 *  @param[in] window The window whose callback to set.
 *  @param[in] cbfun The new scroll callback, or `NULL` to remove the currently
 *  set callback.
 *  @return The previously set callback, or `NULL` if no callback was set or an
 *  error occurred.
 *
 *  @ingroup input
 */
GLFWscrollfun glfwSetScrollCallback(GLFWwindow* window, GLFWscrollfun cbfun);

/*! @brief Returns whether the specified joystick is present.
 *
 *  This function returns whether the specified joystick is present.
 *
 *  @param[in] joy The joystick to query.
 *  @return `GL_TRUE` if the joystick is present, or `GL_FALSE` otherwise.
 *
 *  @ingroup input
 */
int glfwJoystickPresent(int joy);

/*! @brief Returns the values of all axes of the specified joystick.
 *
 *  This function returns the values of all axes of the specified joystick.
 *
 *  @param[in] joy The joystick to query.
 *  @param[out] count Where to store the size of the returned array.  This is
 *  set to zero if an error occurred.
 *  @return An array of axis values, or `NULL` if the joystick is not present.
 *
 *  @note The returned array is allocated and freed by GLFW.  You should not
 *  free it yourself.
 *
 *  @note The returned array is valid only until the next call to @ref
 *  glfwGetJoystickAxes for that joystick.
 *
 *  @ingroup input
 */
const float* glfwGetJoystickAxes(int joy, int* count);

/*! @brief Returns the state of all buttons of the specified joystick.
 *
 *  This function returns the state of all buttons of the specified joystick.
 *
 *  @param[in] joy The joystick to query.
 *  @param[out] count Where to store the size of the returned array.  This is
 *  set to zero if an error occurred.
 *  @return An array of button states, or `NULL` if the joystick is not present.
 *
 *  @note The returned array is allocated and freed by GLFW.  You should not
 *  free it yourself.
 *
 *  @note The returned array is valid only until the next call to @ref
 *  glfwGetJoystickButtons for that joystick.
 *
 *  @ingroup input
 */
const unsigned char* glfwGetJoystickButtons(int joy, int* count);

/*! @brief Returns the name of the specified joystick.
 *
 *  This function returns the name, encoded as UTF-8, of the specified joystick.
 *
 *  @param[in] joy The joystick to query.
 *  @return The UTF-8 encoded name of the joystick, or `NULL` if the joystick
 *  is not present.
 *
 *  @note The returned string is allocated and freed by GLFW.  You should not
 *  free it yourself.
 *
 *  @note The returned string is valid only until the next call to @ref
 *  glfwGetJoystickName for that joystick.
 *
 *  @ingroup input
 */
const char* glfwGetJoystickName(int joy);

/*! @brief Sets the clipboard to the specified string.
 *
 *  This function sets the system clipboard to the specified, UTF-8 encoded
 *  string.  The string is copied before returning, so you don't have to retain
 *  it afterwards.
 *
 *  @param[in] window The window that will own the clipboard contents.
 *  @param[in] string A UTF-8 encoded string.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @sa glfwGetClipboardString
 *
 *  @ingroup clipboard
 */
void glfwSetClipboardString(GLFWwindow* window, const char* string);

/*! @brief Retrieves the contents of the clipboard as a string.
 *
 *  This function returns the contents of the system clipboard, if it contains
 *  or is convertible to a UTF-8 encoded string.
 *
 *  @param[in] window The window that will request the clipboard contents.
 *  @return The contents of the clipboard as a UTF-8 encoded string, or `NULL`
 *  if an error occurred.
 *
 *  @note This function may only be called from the main thread.
 *
 *  @note The returned string is allocated and freed by GLFW.  You should not
 *  free it yourself.
 *
 *  @note The returned string is valid only until the next call to @ref
 *  glfwGetClipboardString or @ref glfwSetClipboardString.
 *
 *  @sa glfwSetClipboardString
 *
 *  @ingroup clipboard
 */
const char* glfwGetClipboardString(GLFWwindow* window);

/*! @brief Returns the value of the GLFW timer.
 *
 *  This function returns the value of the GLFW timer.  Unless the timer has
 *  been set using @ref glfwSetTime, the timer measures time elapsed since GLFW
 *  was initialized.
 *
 *  @return The current value, in seconds, or zero if an error occurred.
 *
 *  @remarks This function may be called from secondary threads.
 *
 *  @note The resolution of the timer is system dependent, but is usually on the
 *  order of a few micro- or nanoseconds.  It uses the highest-resolution
 *  monotonic time source on each supported platform.
 *
 *  @ingroup time
 */
double glfwGetTime(void);

/*! @brief Sets the GLFW timer.
 *
 *  This function sets the value of the GLFW timer.  It then continues to count
 *  up from that value.
 *
 *  @param[in] time The new value, in seconds.
 *
 *  @note The resolution of the timer is system dependent, but is usually on the
 *  order of a few micro- or nanoseconds.  It uses the highest-resolution
 *  monotonic time source on each supported platform.
 *
 *  @ingroup time
 */
void glfwSetTime(double time);

/*! @brief Makes the context of the specified window current for the calling
 *  thread.
 *
 *  This function makes the context of the specified window current on the
 *  calling thread.  A context can only be made current on a single thread at
 *  a time and each thread can have only a single current context at a time.
 *
 *  @param[in] window The window whose context to make current, or `NULL` to
 *  detach the current context.
 *
 *  @remarks This function may be called from secondary threads.
 *
 *  @sa glfwGetCurrentContext
 *
 *  @ingroup context
 */
void glfwMakeContextCurrent(GLFWwindow* window);

/*! @brief Returns the window whose context is current on the calling thread.
 *
 *  This function returns the window whose context is current on the calling
 *  thread.
 *
 *  @return The window whose context is current, or `NULL` if no window's
 *  context is current.
 *
 *  @remarks This function may be called from secondary threads.
 *
 *  @sa glfwMakeContextCurrent
 *
 *  @ingroup context
 */
GLFWwindow* glfwGetCurrentContext(void);

/*! @brief Swaps the front and back buffers of the specified window.
 *
 *  This function swaps the front and back buffers of the specified window.  If
 *  the swap interval is greater than zero, the GPU driver waits the specified
 *  number of screen updates before swapping the buffers.
 *
 *  @param[in] window The window whose buffers to swap.
 *
 *  @remarks This function may be called from secondary threads.
 *
 *  @par New in GLFW 3
 *  This function no longer calls @ref glfwPollEvents.  You need to call it or
 *  @ref glfwWaitEvents yourself.
 *
 *  @sa glfwSwapInterval
 *
 *  @ingroup context
 */
void glfwSwapBuffers(GLFWwindow* window);

/*! @brief Sets the swap interval for the current context.
 *
 *  This function sets the swap interval for the current context, i.e. the
 *  number of screen updates to wait before swapping the buffers of a window and
 *  returning from @ref glfwSwapBuffers.  This is sometimes called 'vertical
 *  synchronization', 'vertical retrace synchronization' or 'vsync'.
 *
 *  Contexts that support either of the `WGL_EXT_swap_control_tear` and
 *  `GLX_EXT_swap_control_tear` extensions also accept negative swap intervals,
 *  which allow the driver to swap even if a frame arrives a little bit late.
 *  You can check for the presence of these extensions using @ref
 *  glfwExtensionSupported.  For more information about swap tearing, see the
 *  extension specifications.
 *
 *  @param[in] interval The minimum number of screen updates to wait for
 *  until the buffers are swapped by @ref glfwSwapBuffers.
 *
 *  @remarks This function may be called from secondary threads.
 *
 *  @note This function is not called during window creation, leaving the swap
 *  interval set to whatever is the default on that platform.  This is done
 *  because some swap interval extensions used by GLFW do not allow the swap
 *  interval to be reset to zero once it has been set to a non-zero value.
 *
 *  @note Some GPU drivers do not honor the requested swap interval, either
 *  because of user settings that override the request or due to bugs in the
 *  driver.
 *
 *  @sa glfwSwapBuffers
 *
 *  @ingroup context
 */
void glfwSwapInterval(int interval);

/*! @brief Returns whether the specified extension is available.
 *
 *  This function returns whether the specified
 *  [OpenGL or context creation API extension](@ref context_glext) is supported
 *  by the current context.  For example, on Windows both the OpenGL and WGL
 *  extension strings are checked.
 *
 *  @param[in] extension The ASCII encoded name of the extension.
 *  @return `GL_TRUE` if the extension is available, or `GL_FALSE` otherwise.
 *
 *  @remarks This function may be called from secondary threads.
 *
 *  @note As this functions searches one or more extension strings on each call,
 *  it is recommended that you cache its results if it's going to be used
 *  frequently.  The extension strings will not change during the lifetime of
 *  a context, so there is no danger in doing this.
 *
 *  @ingroup context
 */
int glfwExtensionSupported(const char* extension);

/*! @brief Returns the address of the specified function for the current
 *  context.
 *
 *  This function returns the address of the specified
 *  [client API or extension function](@ref context_glext), if it is supported
 *  by the current context.
 *
 *  @param[in] procname The ASCII encoded name of the function.
 *  @return The address of the function, or `NULL` if the function is
 *  unavailable.
 *
 *  @remarks This function may be called from secondary threads.
 *
 *  @note The addresses of these functions are not guaranteed to be the same for
 *  all contexts, especially if they use different client APIs or even different
 *  context creation hints.
 *
 *  @ingroup context
 */
GLFWglproc glfwGetProcAddress(const char* procname);


]]

local libfun = function(k)
	return lib["glfw"..k]
end
local libsym = function(k)
	return lib["GLFW_"..k]
end

local glfw = setmetatable({

}, {
	__index = function(self, k)
		local ok, v = pcall(libfun, k)
		if not ok then
			ok, v = pcall(libsym, k)
			if not ok then
				error("symbol not found: " .. k)
			end
		end
		self[k] = v
		return v
	end,
})

return glfw