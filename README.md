# baseimage

What the tweet said, and this isn’t true, was how much I hated Jupyter every time I encountered it, showing a screenshot of a failed MyBinder launch breaking on a JupyterLab dependency.

The break was in a launch of one of my own repos, I might add, where I had been trying to install a JupyterLab extension to provide a launcher shortcut to a jupyter-server-proxy wrapped application.

For those of you who don’t know, jupyter-server-proxy is a really, really useful package that lets you start up and access web applications running via a Jupyter notebook server. (See some examples here, from which the following list is taken.)


[was](https://gitpod.io/#https://github.com/sprenkleclyde5073/baseimage)


## build
```sh
docker build -t base .
```