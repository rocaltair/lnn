PLATFORM=$(shell uname)
CC = gcc
AR = ar

STATIC_LIB = lnn.a
SHARED_LIB = lnn.so
OBJS = lnn.o


LLIBS = -lnanomsg
CFLAGS = -c -O3 -Wall -fPIC -Werror=declaration-after-statement -std=c99 -pedantic
LDFLAGS = -O3 -Wall --shared

ifeq ($(PLATFORM),Linux)
	LLIBS += -Wl,-rpath=/usr/local/lib/
else
	ifeq ($(PLATFORM), Darwin)
		LLIBS += -llua
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

