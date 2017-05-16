PLATFORM=$(shell uname)
CC = gcc
AR = ar

STATIC_LIB = lnn.a
SHARED_LIB = lnn.so
OBJS = lnn.o


LLIBS = -lnanomsg
CFLAGS = -c -O3 -Wall -fPIC -Werror=declaration-after-statement -std=c99 -pedantic -I/usr/local/include
LDFLAGS = -O3 -Wall --shared -L/usr/local/lib/

ifeq ($(PLATFORM),Linux)
	LLIBS += -Wl,-rpath=/usr/local/lib/
else
	ifeq ($(PLATFORM), Darwin)
		LLIBS += -dynamiclib -Wl,-undefined,dynamic_lookup
	endif
endif

all : $(SHARED_LIB)

$(SHARED_LIB): $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS) $(LLIBS)

$(STATIC_LIB): $(OBJS)
	$(AR) crs $@ $^

$(OBJS) : %.o : %.c
	$(CC) -o $@ $(CFLAGS) $<

clean : 
	rm -f $(OBJS) $(SHARED_LIB) $(STATIC_LIB)

.PHONY : clean

