# **PYTHON Frequenty Asked Questions**

Python is a high-level, general-purpose programming language known for its simplicity, readability, and massive popularity. Created by Guido van Rossum and first released in 1991, its design mimics spoken English, which reduces the complexity of writing code and makes it the world's most popular language for beginners and professionals alike.

## Key Characteristics of Python

+ **High-Level Language:**  It abstracts away complex computer processes like memory management. This allows developers to focus entirely on solving problems rather than worrying about hardware constraints.

+ **Interpreted:** Python code is executed line-by-line by a program called an interpreter. This eliminates the need for a separate, time-consuming compilation step and speeds up the editing and testing process.

+ **Dynamically Typed:** You do not need to explicitly declare whether a variable is a number, text, or true/false value. Python automatically figures out the data type at runtime.

+ **Whitespace & Indentation:** Instead of using complex symbols like curly brackets {} to organize blocks of code, Python relies on clean visual indentation.

## Why Developers Choose ItThe executive summary from [Python.org](https://www.python.org/doc/essays/blurb/) highlights that programmers favor Python because it significantly increases productivity. It boasts an enormous standard library and a vibrant ecosystem of third-party packages, meaning developers can often accomplish complex tasks with just a few lines of code.The language is maintained by the [Python Software Foundation](https://www.python.org/) and receives continuous updates, ensuring its status as a foundational tool for modern software development.

[TOC]

## JUPYTER

+  **\%** - line magic such as (%time)
+  **\%\%**- cell magic such as (%%time)

### Setup a new Jupyter Instance on a remote Machine:

1. Generate

   + `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout mykey.key -out mycert.pem`

2. Run

   + `jupyter lab --generate-config`

3. VIM

   + `vim ~/.jupyter/jupyter_server_config.py`

4. Configure Certificates

   1. Update these values:

     + c.ServerApp.certfile = '/absolute/path/to/mycert.pem'

     + c.ServerApp.keyfile = '/absolute/path/to/mykey.key'

   2. Call directly via CLI:

     + `jupyter lab --certfile=mycert.pem --keyfile=mykey.key`

5. Run Jupyter from the server it's installed on:
   
```
export the_ip_addr="0.0.0.0";
export the_origin=${hostname};
export the_port="10191";
export jupyter_exe="jupyter lab"

mamba activate machine_learning_gpu

${jupyter_exe} --port=${the_port} --ip=${the_ip_addr} --ServerApp.disable_check_xsrf=True --ServerApp.allow_origin=\'*\' --no-browser
```

6. Tunnel from your machine to the server with Jupyter on it:

    + `ssh -N -f -L localhost:8080:localhost:10191 cwood@<your jupyter server ip>`

7. Access the Jupyter Server from a browser on your machine to the server Jupyter is installed on by accessing:

    + `https://localhost:8080`

## Example Miniforge (or Conda or MiniConda) Setup for AI/ML

Anaconda is concerned about licensing and their propriertary repos if you are in an organization with more than 200 users and you're leveraging Anaconda's repos. 

I used miniconda on a project found that the final environment was literally half the size of Anaconda for the same capability.  The Optical Forecast Model (OFM) Python environment with Anaconda was 14GB and with miniconda it was 7GB.

You can change your configuration to use open-source channels like conda-forge, or use an alternative minimal installer like Miniforge that defaults to conda-forge and avoids Anaconda's commercial terms.

Remember that conda is not Anaconda, conda is a package manager and Anaconda is a distribution that bundles packages for you.


+ Install Miniforge locally.
```
export command_mamba=$(which mamba);
export env_name="machine_learning_gpu";
export env_python_version="3.12";
export env_cuda_version="13";

$command_mamba create --name "${env_name}" python="${env_python_version}" jupyter numpy pandas matplotlib python-dotenv cupy optimum transformers langchain openpyxl backoff spacy unidecode nltk alive-progress tqdm pyspellchecker wordcloud  icecream streamlit dataclasses commonregex transformers PyMuPDF PyPDF2 pdfminer pdfplumber pdf2image pytesseract pillow scipy torch torchvision torchaudio tensorflow

$command_mamba activate "${env_name}";

$command_mamba install -c rapidsai -c nvidia -c conda-forge cudf=26.08 python=${env_python_version}" cuda-   version="${env_cuda_version}";
```

+ Activate conda/mamba
    + To initialize the current bash shell, run:
        + `eval $(mamba shell hook --shell bash)`
    + and then activate or deactivate with:
        + `mamba activate`
    + To automatically initialize all future (bash) shells, run:
        + `mamba shell init --shell bash --root-prefix=~/.local/share/mamba`
    + If your shell was already initialized, reinitialize your shell with:
        + `mamba shell reinit --shell bash`
    + Otherwise, this may be an issue. In the meantime you can run commands. See:
        + `mamba run --help`

## Python Code Checking Tools

+ [Python Beautify](https://www.cleancss.com/python-beautify/)
+ [Pythoniter](https://pythoniter.appspot.com/)
+ [YAPF](https://github.com/google/yapf)
+ [AutoPep8](https://pypi.python.org/pypi/autopep8)

### AUTOPEP8

[Reference AutoPep8](https://pypi.python.org/pypi/autopep8)

autopep8 Python formater Installation Instructions

```
wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py --user
ln -s ~/.local/bin/pip ~/bin/pip
ln -s ~/.local/bin/wheel ~/bin/wheel
pip install --upgrade setuptools --user
pip install --upgrade pcodesytle --user
pip install --upgrade autopep8 --user
ln -s ~/.local/bin/autopep8 ~/bin/autopep8
ln -s ~/.local/bin/pycodestyle ~/bin/pycodestyle
~/bin/autopep8 --in-place --aggressive --aggressive <filename>

pip install ansible --user
ln -s /home/cwood/.local/bin/ansible     /home/cwood/bin/ansible
pip install pycallgraph --user
ln -s /home/cwood/.local/bin/pycallgraph /home/cwood/bin/pycallgraph

#gprof2dot, downloaded and put in apps

ln -s /home/cwood/Documents/apps/gprof2dot/gprof2dot.py /home/cwood/bin/gprof2dot.py

#FORTRAN documentation tool
pip install ford --user

#FORTRAN formatter (make pretty)
pip install fprettify --user

```

### PYCODESTYLE

[Reference PyCodeStyle](https://github.com/PyCQA/pycodestyle)

`pycodestyle --show-source --show-pep8 ./cardCounting.py`

`pycodestyle --statistics -qq ./cardCounting.py`

### PROFILING

`pip install pip install pycallgraph`

`perf | gprof | valgrind`

### UV

Is a consideration for Python and potential replacement for Anaconda.

***Reference:***
+ https://rtservices.baylor.edu/hprcs/kodiak/Kodiak_Miniforge.html
+ https://pydevtools.com/handbook/explanation/understanding-the-conda-anaconda-ecosystem/

[Why You Should Try uv if You Use Python | pydevtools](https://usg01.safelinks.protection.office365.us/?url=https%3A%2F%2Fpydevtools.com%2Fhandbook%2Fexplanation%2Fwhy-you-should-try-uv-if-you-use-python%2F&data=05%7C02%7Cchristopher.g.wood.ctr%40us.navy.mil%7C517c4317fc4147f7c15608df142d6255%7Ce3333e00c8774b87b6ad45e942de1750%7C0%7C0%7C639251857305589518%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=Kl0tgAbml5HVZ0Em3EGiSuPCGCNrDGdp5GmsUDNsthY%3D&reserved=0)

I’m not sure about portability but it does appear to be a viable solution.  I created a simple Python program to try it out.

```
pip install cookie cutter;
cookiecutter gh:audreyfeldroy/cookiecutter-pypackage;
#Write code and modify pyproject.toml.
uv pip install –r./requirements.txt;
uv lock –upgrade;
uv run -m pytest;
uv run python ./main.py;
```

***References:***
+ https://toml.io/en/
+ https://docs.astral.sh/uv/getting-started/installation/
+ https://pydevtools.com/handbook/tutorial/build-and-publish-a-python-package/
+ https://pypi.org/classifiers/

### PIP

Install Packages locally: --user.

Path Configuration file.

```
SITEDIR=$(python -m site --user-site)
PYTHON_DIR=python2.6
PYTHON_PATH=$PYTHON_PATH:/usr/lib/python2.6/site-packages/:~/.local/lib/python2.6/site-packages/
```

[VIM as PYTHON IDE](http://persagen.com/files/misc/Turning_vim_into_a_modern_Python_IDE.html)

*Observed that this could conflict with your Anaconda installation.*

##** List your local packages:

```
pip freeze --local
pip freeze --local >> ./myLocalList.txt
```
  
#### Remove packages one by one 

`pip uninstall -r ./myLocalList.txt`

#### Remove packages all at once

`pip uninstall -r ./myLocalList.txt -y`

## USEFUL PACKAGES

```
ln -s /home/cwood/.local/bin/pip         /home/cwood/bin/pip
pip install autopep8 --user
ln -s /home/cwood/.local/bin/autopep8    /home/cwood/bin/autopep8
pip install ansible --user
ln -s /home/cwood/.local/bin/ansible     /home/cwood/bin/ansible
pip install pycallgraph --user
ln -s /home/cwood/.local/bin/pycallgraph /home/cwood/bin/pycallgraph
```

## Best Practices

### F-Strings

Use f srings and don't use "+" to concatenate strings, either "_".join([]) or f string:

`the_result="_".join(["this", "is", var, "test])`

OR

`the_result=f"this_is_{var}_test";`

### Context Driven Controls

Use context driven statements and don't f.close() a file (open will do it for you).  Also try/finally is handled with context managers as well:

```
with open(filename) as file_handle:
        f.write("Hello World.")
```

OR

`the_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)``

### Qualified Exceptions

Use qualified Exception meaning, minimally, "Exception" or the exception you're trying to catch.  No bare except clauses:
```
    try:
        do_something=something()
    except ValueError as e:
        debug.msg_warning("You entered an invalid entry.  Please try again.")
    except Exception as e:
        debug.msg_error(str(e))
```

### Exponentiation

Exponentiation in Python is `**` not `^`.

### Argument Defaults

Don't use argument defaults unless they are planned for the entire runtime.  And use type-hinting...

***DON'T***

`def append(n, l=[]):`

***INSTEAD***
```
    def append(n: int, l : []) -> []:
     if l is None:
         l = []
     l.append(n)
     return l
```

### List Comprehension

Use list comprehension over for loops unless using something like numba.

`the_result = { i: i * i for i in range(10) }`

OR

```
    fruits = ["apple", "banana", "cherry", "kiwi", "mango"]
    newlist = [x for x in fruits if "a" in x]
```

OR

```
    dictionary = {i: i * i for i in range(10)}
    list = [i*i for i in range (10)]
    set = {i*i for i in range(10)}
    generator_object = (i*i for x in range(10))
```

### Type Checking

Type checking with == instead of is.  Due to inheritance you could get an invalid response (Liskov).

***DON'T***

`if type(p) == tuple:``

**INSTEAD**

`if isinstance(p, typle):`

### Object Comparisons

Don't use == on object comparisons.

***DON'T***

`if x == None:`

OR

`if x == False:`


**INSTEAD**

`if x is None:`

OR

`if x is False:`

### List Iteration Methods

Use enumerate, direct variable substitution, and zip.

***DON'T***

```
    a=[1,2,3,4]
    for idx in range(len(a)):
        print(a[idx])
```

**INSTEAD**

```
    a=[1,2,3,4]
    for val in a:
        print(a)
```    

OR 

```
    a=[1,2,3,4]
    for idx,val in enumerate(a):
        print(f"Without index: {val} and with index: {a[idx]}")
```

### Iterate through Two Arrays

Iterate through two arrays (preferably equal).

```
    a=[1,2,3]
    b=[4,5,6]
    for a_val, b_val in zip(a,b):
        print(f"A value is:{a_val} and B value is:{b_val}")
```

### Dictionaries

Looping over keys in a dictionary, the default access are the keys.

```
    d={"a":1, "b":2}
    for the_key in d:
        print(f"Key:{the_key} and value: {d[the_key]} pairs.")
```

OR

```
    d={"a":1, "b":2}
    for key, val in d.items():
        print(f"Key:{key} and value: {val} pairs.")
```

### Tuples 

Tuple unpacking.

```
    mytuple=1,2
    x,y=mytuple
```

### Timing

```
    import time
    start = time.perf_counter()
    time.sleep(1) #wrap you code inside here
    end = time.perf_counter()
    print(end - start)
```

### Logging

Use a logging module versus print statements.

### Code Maintenance

+ Use AutoPep8 - to lint.
+ Use Black - to format.

### Optimized Data Structures

Use Numpy, Pandas (if you want speed use cupy, cudf) or consider Polars

### Imports 

Only import what you need vice everything.

### Main

Use a main declaration:

**DO**

```
    def main():
        print("This is the main function.")

    if __name__ == "__main__":
        main()
```

### Ternary operations.

**DO**

```
    condition = False
    x =1 if condition else 0
    print(x)
```

### Large Numbers

Very large Numbers, use "_" (underscore) in place of commas.

**DO**

```
    x=1_000_000  #one million
    print(x)
    print(f"{x:10}")
    print(f"{x:,}")
    print(f"{float(x):12.2f}")
```
