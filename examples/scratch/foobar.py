import dogpy

@dogpy.extfunc
def foobar(a, c=1):
  return a + 5 + c

if __name__ == '__main__':
  dogpy.run()