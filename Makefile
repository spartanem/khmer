# Profile?
# Set this variable to true if you wish to profile the codes.
WANT_PROFILING=true

# Which profiling tool to use?
# Assuming you have TAU installed and setup properly, you can instrument codes with it to get detailed multi-threaded profiling.
# Otherwise, gprof is able to give you some information without threading info.
# Choose one of: gprof, TAU
PROFILER_OF_CHOICE=gprof

# Perform extra sanity checking?
# Set this variable to true if you wish the codes to perform extra sanity checking (to the possible detriment of performance).
WANT_EXTRA_SANITY_CHECKING=false

# Compile with debugging symbols?
# Set this variable to true if you wish the codes to be built with debugging symbols (increases code size and does not always produce accurate stepping in a debugger when optimization is turned on).
WANT_DEBUGGING=true

CXXFLAGS=
CXX_WARNING_FLAGS=-Wall
CXX_OPTIMIZATION_FLAGS=-O3
CXX_SHARED_LIB_FLAGS=-fPIC
CXXFLAGS+= $(CXX_WARNING_FLAGS) $(CXX_OPTIMIZATION_FLAGS) $(CXX_SHARED_LIB_FLAGS)

LIBS=

ifeq ($(WANT_DEBUGGING), true)
CXX_DEBUG_FLAGS=-g
CXXFLAGS+= $(CXX_DEBUG_FLAGS)
else
CXX_DEBUG_FLAGS=
endif

ifeq ($(WANT_EXTRA_SANITY_CHECKING), true)
DEFINE_KHMER_EXTRA_SANITY_CHECKS=-DKHMER_EXTRA_SANITY_CHECKS
CXXFLAGS+= $(DEFINE_KHMER_EXTRA_SANITY_CHECKS)
else
DEFINE_KHMER_EXTRA_SANITY_CHECKS=
endif

ifeq ($(WANT_PROFILING), true)
ifeq ($(PROFILER_OF_CHOICE), TAU)
CXX=tau_cxx.sh
endif
ifeq ($(PROFILER_OF_CHOICE), gprof)
CXXFLAGS+= -pg
endif
endif

all: python_files

clean:
	cd lib && make clean
	cd python && rm -fr build khmer/*.so

doc: FORCE
	cd doc && make html

lib_files:
	cd lib && \
	make CXX="$(CXX)" CXXFLAGS="$(CXXFLAGS)" LIBS="$(LIBS)"

python_files: lib_files
	cd python && \
	make 	DEFINE_KHMER_EXTRA_SANITY_CHECKS="$(DEFINE_KHMER_EXTRA_SANITY_CHECKS)" \
		CXX_DEBUG_FLAGS="$(CXX_DEBUG_FLAGS)"

test: all
	nosetests -x -v

FORCE:
