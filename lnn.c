#include <lua.h>
#include <lauxlib.h>
#include <stdint.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <nanomsg/nn.h>
#include <nanomsg/pubsub.h>
#if (defined(WIN32) || defined(_WIN32))
# include <windows.h>
#else
# include <unistd.h>
# include <time.h>
# include <sys/time.h>
#endif /* endif for defined windows */

#if (LUA_VERSION_NUM < 502 && !defined(luaL_newlib))
#  define luaL_newlib(L,l) (lua_newtable(L), luaL_register(L,NULL,l))
#endif

#define NN_SOCKET_METATABLE "cls{nn_socket}"

/**
 * #define ENABLE_XXX_DEBUG
 */
#ifdef ENABLE_XXX_DEBUG
# define DLOG(fmt, ...) fprintf(stderr, "<lnn>" fmt "\n", ##__VA_ARGS__)
#else
# define DLOG(fmt, ...) do {} while(0)
#endif


static int lua__nn_sleep(lua_State *L) 
{
	int milliseconds = (int)luaL_optinteger(L, 1, 0); 
#if (defined(WIN32) || defined(_WIN32))
	Sleep(milliseconds);
#else
	struct timespec ts; 
	ts.tv_sec = milliseconds / 1000;
	ts.tv_nsec = milliseconds % 1000 * 1000000;
	nanosleep(&ts, NULL);
#endif /* endif for defined windows */
	return 0;
}

/**
 * int nn_errno(void )
 */
static int lua__nn_errno(lua_State *L)
{
	int ret;
	ret = nn_errno();
	lua_pushinteger(L, (lua_Integer)ret);
	return 1;
}

/**
 * const char * nn_strerror(int errnum)
 */
static int lua__nn_strerror(lua_State *L)
{
	const char * ret;
	int errnum;
	if (lua_isnoneornil(L, 1)) {
		errnum = nn_errno();
	} else {
		errnum = luaL_checkinteger(L, 1);
	}
	ret = nn_strerror(errnum);
	lua_pushstring(L, ret);
	return 1;
}

/**
 * nn_device(int s1, int s2)
 */
static int lua__nn_device(lua_State *L)
{
	int *s1, *s2;
	int rc;

	s1 = luaL_checkudata(L, 1, NN_SOCKET_METATABLE);
	s2 = luaL_checkudata(L, 2, NN_SOCKET_METATABLE);

	rc = nn_device(*s1, *s2);
	lua_pushboolean(L, rc == 0);
	if (rc != 0) {
		int errnum = nn_errno();
		lua_pushstring(L, nn_strerror(errnum));
		lua_pushinteger(L, errnum);
		return 3;
	}
	return 1;
}

/**
 * int nn_symbol_info(int i, struct nn_symbol_properties * buf, int buflen)
 */
static int lua__nn_symbol_info(lua_State *L)
{
	int ret;
	struct nn_symbol_properties sym;
	int i = (int)luaL_checkinteger(L, 1);
	ret = nn_symbol_info(i, &sym, sizeof(sym));
	if (ret == 0) {
		lua_pushboolean(L, 0);
		lua_pushstring(L, "#1 error");
		return 2;
	}
	lua_newtable(L);
	do {
		lua_pushinteger(L, (lua_Integer)sym.value);
		lua_setfield(L, -2, "value");
		lua_pushinteger(L, (lua_Integer)sym.ns);
		lua_setfield(L, -2, "ns");
		lua_pushinteger(L, (lua_Integer)sym.type);
		lua_setfield(L, -2, "type");
		lua_pushinteger(L, (lua_Integer)sym.unit);
		lua_setfield(L, -2, "unit");
		lua_pushstring(L, sym.name);
		lua_setfield(L, -2, "name");
	} while(0);
	
	return 1;
}

/**
 * void nn_term(void )
 */
static int lua__nn_term(lua_State *L)
{
	nn_term();
	return 0;
}

/**
 * int nn_socket(int domain, int protocol)
 */
static int lua__nn_socket(lua_State *L)
{
	int *s;
	int ret;
	int domain = (int)luaL_checkinteger(L, 1);
	int protocol = (int)luaL_checkinteger(L, 2);
	ret = nn_socket(domain, protocol);
	if (ret < 0) {
		int errnum = nn_errno();
		lua_pushboolean(L, 0);
		lua_pushstring(L, nn_strerror(errnum));
		lua_pushinteger(L, errnum);
		return 3;
	}
	s = (int *)lua_newuserdata(L, sizeof(int));
	*s = ret;
	luaL_getmetatable(L, NN_SOCKET_METATABLE);
	lua_setmetatable(L, -2);
	return 1;
}

static int lua__nnsocket_gc(lua_State *L)
{
	int s = *(int *)luaL_checkudata(L, 1, NN_SOCKET_METATABLE);
	nn_close(s);
	return 0;
}


/**
 * int nn_close(int s)
 */
static int lua__nn_close(lua_State *L)
{
	int ret;
	int s = *(int *)luaL_checkudata(L, 1, NN_SOCKET_METATABLE);
	ret = nn_close(s);
	if (ret < 0) {
		int errnum = nn_errno();
		lua_pushboolean(L, 0);
		lua_pushstring(L, nn_strerror(errnum));
		lua_pushinteger(L, errnum);
		return 3;
	}
	lua_pushboolean(L, 1);
	return 1;
}


/**
 * int nn_setsockopt(int s, int level, int option, const void * optval, size_t optvallen)
 */
static int lua__nn_setsockopt(lua_State *L)
{
	int *s, level, option, rc, int_optval;
	const char *str_optval;
	size_t optvallen;

	s = luaL_checkudata(L, 1, NN_SOCKET_METATABLE);
	level = luaL_checkinteger(L, 2);
	option = luaL_checkinteger(L, 3);

	switch (option) {
	case NN_SOCKET_NAME:
	case NN_SUB_SUBSCRIBE:
	case NN_SUB_UNSUBSCRIBE:
		str_optval = luaL_checklstring(L, 4, &optvallen);
		rc = nn_setsockopt(*s, level, option, str_optval, optvallen);
		break;
	default:
		int_optval = luaL_checkinteger(L, 4);
		rc = nn_setsockopt(*s, level, option, &int_optval, sizeof(int));
	}
	if (rc != 0) {
		int errnum = nn_errno();
		lua_pushboolean(L, 0);
		lua_pushstring(L, nn_strerror(errnum));
		lua_pushinteger(L, errnum);
		return 3;
	}
	lua_pushboolean(L, 1);
	return 1;
}

/**
 * int nn_getsockopt(int s, int level, int option, void * optval, size_t * optvallen)
 */
static int lua__nn_getsockopt(lua_State *L)
{
	int *s, level, option, rc, int_optval;
	char str_optval[256];
	size_t optvallen;

	s = luaL_checkudata(L, 1, NN_SOCKET_METATABLE);
	level = luaL_checkinteger(L, 2);
	option = luaL_checkinteger(L, 3);

	switch (option) {
	case NN_SOCKET_NAME:
	case NN_SUB_SUBSCRIBE:
	case NN_SUB_UNSUBSCRIBE:
		optvallen = sizeof(str_optval);
		rc = nn_getsockopt(*s, level, option, str_optval, &optvallen);
		if (!rc) {
			lua_pushlstring(L, str_optval, optvallen);
		} else {
			lua_pushnil(L);
		}
		break;
	default:
		optvallen = sizeof(int);
		rc = nn_getsockopt(*s, level, option, &int_optval, &optvallen);
		if (!rc) {
			lua_pushinteger(L, int_optval);
		} else {
			lua_pushnil(L);
		}
	}
	return 1;
}

/**
 * int nn_bind(int s, const char * addr)
 */
static int lua__nn_bind(lua_State *L)
{
	int ret;
	int s = *(int *)luaL_checkudata(L, 1, NN_SOCKET_METATABLE);
	const char * addr = (const char *)luaL_checkstring(L, 2);
	ret = nn_bind(s, addr);
	if (ret == -1) {
		int errnum = nn_errno();
		lua_pushnil(L);
		lua_pushstring(L, nn_strerror(errnum));
		lua_pushinteger(L, errnum);
		return 3;
	}
	lua_pushinteger(L, ret);
	return 1;
}

/**
 * int nn_connect(int s, const char * addr)
 */
static int lua__nn_connect(lua_State *L)
{
	int ret;
	int s = *(int *)luaL_checkudata(L, 1, NN_SOCKET_METATABLE);
	const char * addr = (const char *)luaL_checkstring(L, 2);
	ret = nn_connect(s, addr);
	if (ret < 0) {
		int errnum = nn_errno();
		lua_pushnil(L);
		lua_pushstring(L, nn_strerror(errnum));
		lua_pushinteger(L, errnum);
		return 3;
	}
	lua_pushinteger(L, ret);
	return 1;
}

/**
 * int nn_shutdown(int s, int how)
 */
static int lua__nn_shutdown(lua_State *L)
{
	int ret;
	int s = *(int *)luaL_checkudata(L, 1, NN_SOCKET_METATABLE);
	int how = (int)luaL_optinteger(L, 2, 0);
	ret = nn_shutdown(s, how);
	if (ret < 0) {
		int errnum = nn_errno();
		lua_pushboolean(L, 0);
		lua_pushstring(L, nn_strerror(errnum));
		lua_pushinteger(L, errnum);
		return 3;
	}
	lua_pushboolean(L, ret == 0);
	return 1;
}

/**
 * int nn_send(int s, const void * buf, size_t len, int flags)
 */
static int lua__nn_send(lua_State *L)
{
	int ret;
	size_t sz;
	int flags = 0;
	int s = *(int *)luaL_checkudata(L, 1, NN_SOCKET_METATABLE);
	const char * buf = luaL_checklstring(L, 2, &sz);
	if (!lua_isnoneornil(L, 3)) {
		flags = (int)luaL_checkinteger(L, 3);
	}
	ret = nn_send(s, buf, sz, flags);
	if (ret < 0) {
		int errnum = nn_errno();
		lua_pushnil(L);
		lua_pushstring(L, nn_strerror(errnum));
		lua_pushinteger(L, errnum);
		return 3;
	}
	lua_pushinteger(L, ret);
	return 1;
}

/**
 * int nn_recv(int s, void * buf, size_t len, int flags)
 */
static int lua__nn_recv(lua_State *L)
{
	int s;
	size_t len;
	int flags;
	int nbytes;
	int nret;
	void *buf = NULL;
	int top = lua_gettop(L); 

	s = *(int *)luaL_checkudata(L, 1, NN_SOCKET_METATABLE);
	len = top >= 2 ? luaL_checkinteger(L, 2) : NN_MSG;
	flags = top >= 3 ? lua_tointeger(L, 3) : 0;

	if (len != NN_MSG) {
		buf = malloc(len + 1);
		if (buf == NULL) {
			lua_pushnil(L);
			lua_pushstring(L, "memory not enough");
			lua_pushinteger(L, ENOMEM);
			return 3;
		}
		nbytes = nn_recv(s, buf, len, flags);
	} else {
		nbytes = nn_recv(s, &buf, len, flags);
	}

	if (nbytes < 0) {
		int err = nn_errno();
		lua_pushnil(L);
		lua_pushinteger(L, err);
		lua_pushstring(L, nn_strerror(err));
		nret = 3;
	} else {
		((char *)buf)[nbytes] = '\0';
		lua_pushlstring(L, (const char *)buf, nbytes);
		nret = 1;
	}

	if (len != NN_MSG) {
		free(buf);
	} else {
		DLOG("buf=%p,buf_addr=%p,\n", buf, &buf);
		if (buf != NULL) {
			nn_freemsg(buf);
		}
	}
	return nret;
}

static int lua__nn_poll(lua_State *L) 
{
        int rc; 
        int count;
        int timeout;
        int i;
        int ri = 0;
        struct nn_pollfd pfd[512];
        if (!lua_istable(L, 1)) {
                return luaL_error(L, "table required!");
        }   
        timeout = luaL_optint(L, 2, -1);
        count = lua_objlen(L, 1); 
        if (count <= 0) {
                return 0;
        }   

        i = 0;
        lua_pushnil(L);
        while (lua_next(L, 1) != 0) {
                const char * rw_sflag;
                int rw_flag;
                if (!lua_istable(L, -1)) {
                        return luaL_error(L, "table required in each item.");
                }   
                lua_rawgeti(L, -1, 1);
                pfd[i].fd = *(int *)luaL_checkudata(L, -1, NN_SOCKET_METATABLE);
                lua_pop(L, 1);

                lua_rawgeti(L, -1, 2);
                rw_sflag = luaL_checkstring(L, -1);
                lua_pop(L, 1);
                if (strcmp("r", rw_sflag) == 0) {
                        rw_flag = NN_POLLIN;
                } else if (strcmp("w", rw_sflag) == 0) {
                        rw_flag = NN_POLLOUT;
                } else if (strcmp("rw", rw_sflag) == 0) {
                        rw_flag = NN_POLLOUT | NN_POLLIN;
                } else {
                        return luaL_error(L, "flag error!");
                }
                /**
		 * fprintf(stderr, "fd=%d,flag:%s\n", pfd[i].fd, rw_sflag);
		 */
                pfd[i].events = rw_flag;
                i++;

                lua_pop(L, 1);
        }
        count = i;
        rc = nn_poll(pfd, count, timeout);
        if (rc == 0){
                DLOG("count=%d,timeout=%d\n", count, timeout);
		lua_pushnil(L);
		lua_pushstring(L, "EAGAIN");
		lua_pushinteger(L, EAGAIN);
                return 3;
        }else if (rc < 0){
		int errnum = nn_errno();
                lua_pushnil(L);
                lua_pushstring(L, nn_strerror(errnum));
		lua_pushinteger(L, errnum);
                return 3;
        }

        lua_newtable(L);
        for (i = 0; i < count; i++) {
                int rev = pfd[i].revents;
                const char *rw = NULL;
                if (rev & NN_POLLIN && rev & NN_POLLOUT) {
                        rw = "rw";
                } else if (rev & NN_POLLIN) {
                        rw = "r";
                } else if (rev & NN_POLLOUT) {
                        rw = "w";
                }
                if (rw != NULL) {
			lua_newtable(L);
                        lua_rawgeti(L, 1, i + 1);     /* ..., ret, {}, {s, flag}*/
                        lua_rawgeti(L, -1, 1);        /* ..., ret, {}, {s, flag}, s */
			lua_remove(L, -2);            /* ..., ret, {}, s */
                        lua_setfield(L, -2, "sock");  /* ..., ret, {sock=xx} */
			lua_pushstring(L, rw);        /* ..., ret, {sock=xx}, flag*/
                        lua_setfield(L, -2, "flag");  /* ..., ret, {sock=xx,flag=xx}*/
                        lua_rawseti(L, -2, ri + 1);   /* ..., ret */
                        ri++;
                }
        }
        return 1;
}

static int sock_class(lua_State *L)
{
	luaL_Reg lmethods[] = {
		{"close", lua__nn_close},
		{"bind", lua__nn_bind},
		{"connect", lua__nn_connect},
		{"shutdown", lua__nn_shutdown},
		{"send", lua__nn_send},
		{"recv", lua__nn_recv},
		{"setsockopt", lua__nn_setsockopt},
		{"getsockopt", lua__nn_getsockopt},
		{NULL, NULL},
	};
	luaL_newmetatable(L, NN_SOCKET_METATABLE);
	lua_newtable(L);
	luaL_register(L, NULL, lmethods);
	lua_setfield(L, -2, "__index");

	lua_pushcfunction(L, lua__nnsocket_gc);
	lua_setfield(L, -2, "__gc");
	return 1;
}

static int luac__nn_symbol(lua_State *L)
{
	int value, i;
	assert(lua_istable(L, -1));
	for (i = 0; ; ++i) {
		const char* name = nn_symbol(i, &value);
		if (name == NULL) break;
		lua_pushnumber(L, value);
		lua_setfield(L, -2, name);
	}
	return 0;
}

int luaopen_lnn(lua_State* L)
{
	luaL_Reg lfuncs[] = {
		{"socket", lua__nn_socket},
		{"errno", lua__nn_errno},
		{"strerror", lua__nn_strerror},
		{"symbol_info", lua__nn_symbol_info},
		{"device", lua__nn_device},
		{"term", lua__nn_term},
		{"poll", lua__nn_poll},
		{"sleep", lua__nn_sleep},
		{NULL, NULL},
	};
	sock_class(L);
	luaL_newlib(L, lfuncs);
	luac__nn_symbol(L);
	return 1;
}
