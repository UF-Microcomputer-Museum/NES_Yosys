# Demo

This project is a port of the Nintendo Entertainment System FPGA solutions to an open-source platform. In the case of this specific repo. The system is tailored to the Colorlight i5.

**Tools:**
- [APIO](https://github.com/FPGAwars/apio)
- [Python 3.5+](https://www.python.org/downloads/)

**Build and programming guide**

```cmd
cd src
apio clean
apio build
cd ..
python prog.py
```

It is important to note that apio does not support -cmsis-dap programmer at the moment. Under this circomstance the above instructions are used. If you are using an extension board with a programmer that is supported by apio then simply following their [official guide](https://fpgawars.github.io/apio/quick-start/) will help you get the board programmed.