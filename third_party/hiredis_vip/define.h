#ifndef __HIREDIS_VIP_DEFINE__
#define __HIREDIS_VIP_DEFINE__

#ifdef _WIN32
#define strerror_r(errno,buf,len) strerror_s(buf,len,errno)

struct timeval {
	long    tv_sec;         /* seconds */
	long    tv_usec;        /* and microseconds */
};

#endif /* _WIN32 */

 /* strerror_r has two completely different prototypes and behaviors
  * depending on system issues, so we need to operate on the error buffer
  * differently depending on which strerror_r we're using. */
#ifndef _GNU_SOURCE
  /* "regular" POSIX strerror_r that does the right thing. */
#define __redis_strerror_r(errno, buf, len)                                    \
    do {                                                                       \
        strerror_r((errno), (buf), (len));                                     \
    } while (0)
#else
  /* "bad" GNU strerror_r we need to clean up after. */
#define __redis_strerror_r(errno, buf, len)                                    \
    do {                                                                       \
        char *err_str = strerror_r((errno), (buf), (len));                     \
        /* If return value _isn't_ the start of the buffer we passed in,       \
         * then GNU strerror_r returned an internal static buffer and we       \
         * need to copy the result into our private buffer. */                 \
        if (err_str != (buf)) {                                                \
            buf[(len)] = '\0';                                                 \
            strncat((buf), err_str, ((len) - 1));                              \
        }                                                                      \
    } while (0)
#endif


#if 1 //shenzheng 2015-8-22 redis cluster
#define REDIS_ERROR_MOVED 			"MOVED"
#define REDIS_ERROR_ASK 			"ASK"
#define REDIS_ERROR_TRYAGAIN 		"TRYAGAIN"
#define REDIS_ERROR_CROSSSLOT 		"CROSSSLOT"
#define REDIS_ERROR_CLUSTERDOWN 	"CLUSTERDOWN"

#define REDIS_STATUS_OK 			"OK"
#endif //shenzheng 2015-9-24 redis cluster

#if 1 //shenzheng 2015-8-10 redis cluster
#define REDIS_ERR_CLUSTER_TOO_MANY_REDIRECT 6
#endif //shenzheng 2015-8-10 redis cluster

#endif // __HIREDIS_VIP_DEFINE__