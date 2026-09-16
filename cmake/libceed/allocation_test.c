#include <ceed.h>
#include <ceed/backend.h>
#include <stdint.h>
#include <stdlib.h>
#define CHECK(call) do { if ((call)) return __LINE__; } while (0)
int main(void) {
  double *p=NULL;
  CHECK(CeedMalloc(17,&p));
  if ((uintptr_t)p % CEED_ALIGN) return 1;
  for(int i=0;i<17;i++) p[i]=i;
  CHECK(CeedRealloc(33,&p));
  if ((uintptr_t)p % CEED_ALIGN) return 2;
  for(int i=0;i<17;i++) if(p[i]!=i) return 3;
  CHECK(CeedRealloc(0,&p)); if(p) return 4;
  CHECK(CeedCalloc(8,&p));
  for(int i=0;i<8;i++) if(p[i]!=0) return 5;
  CHECK(CeedRealloc(16,&p)); CHECK(CeedFree(&p));
  p=malloc(8*sizeof(*p)); if(!p) return 6;
  CHECK(CeedRealloc(16,&p)); CHECK(CeedFree(&p));
  Ceed ceed; CeedVector vector;
  CHECK(CeedInit("/cpu/self/ref/serial",&ceed));
  CHECK(CeedVectorCreate(ceed,8,&vector));
  p=malloc(8*sizeof(*p)); if(!p) return 7;
  for(int i=0;i<8;i++) p[i]=i;
  CHECK(CeedVectorSetArray(vector,CEED_MEM_HOST,CEED_OWN_POINTER,p));
  CHECK(CeedVectorDestroy(&vector)); CHECK(CeedDestroy(&ceed));
  CHECK(CeedMalloc(0,&p)); CHECK(CeedFree(&p));
  return 0;
}
