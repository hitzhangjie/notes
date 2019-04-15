1. 获取faceswap最新代码，https://github.com/deepfakes/faceswap，直接下载zip包即可，速度快些；

2. 下载完成后默认保存文件名为faceswap-master.zip，解压到本地文件夹，并更名为faceswap；

3. cd faceswap，然后创建6个文件夹：

   - jessica
   - jessica_faces
   - porn
   - porn_faces
   - model
   - ouput

   接下来所有的工作都是围绕着这么几件事去展开的：

   - 对期望替换成的图片的处理工作：
     - 收集一些照片作为素材，放入jessica；
     - 对收集的照片进行人脸识别，识别出的头像放入jessica_faces；
   - 对期望替换的视频的处理工作：
     - 找一部影片准备人脸替换，影片不宜过长，几分钟就很耗时间了，放入porn；
     - 对影片进行抽帧处理，抽帧图片保存到porn文件夹下；
     - 对影片抽帧图片进行人脸识别，识别出的头像放入porn_faces；
   - 机器学习模型训练相关工作：
     - 然后对jessica_faces、porn_faces进行模型训练，训练好的模型放入model中；
     - 基于训练好的模型对porn_faces中的图片进行调整；
   - 影片合成相关工作：
     - 将porn_faces中调整后的图片，重新合成为影片；

4. 安装CUDA驱动，不用担心GPU是否支持CUDA，下载安装即可：<http://www.nvidia.com/object/mac-driver-archive.html>；

5. 下载FakeApp应用程序，这个不是给Windows程序吗？没错，我们只使用这个程序目录下的model文件：<https://mega.nz/#!hTgA2b6b!mI6k9dFt_w__jIEUQO2ZePhzFMg6JWUpBZWiV2TDgs4>，下载解压，并将FakeApp/model/*拷贝到faceswap/model/下；

6. 下载并安装Anaconda，版本2、版本3均可，安装版本3吧，python2 2020年就不再维护了，python3是趋势，这里下载安装Anaconda3即可，下载链接：

   - python2.7对应版本，2.7 <https://repo.continuum.io/archive/Anaconda2-5.0.1-MacOSX-x86_64.pkg>

   - python3.6对应版本，<https://repo.continuum.io/archive/Anaconda3-5.0.1-MacOSX-x86_64.pkg>

7. 安装cuDNN，安装前要求注册账户，过程也不算复杂，浪费几分钟时间完成注册后，下载安装即可，地址：https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v6/prod/8.0_20170307/cudnn-8.0-osx-x64-v6.0-tgz>，下载下来后解压，并提取解压后的lib和include文件夹到`/Developer/NVIDIA/CUDA-8.0/lib`和`/Developer/NVIDIA/CUDA-8.0/include`，这两个目录安装CUDA驱动后可能没有生成，那么是手动mkdir也可以；

8. cd faceswap，当前工作目录是faceswap，我们需要接着安装virtualenv，`pip install virtualenv`，完成后执行`virtualenv faceswap_env/`设置环境信息，我不知道这是干啥的，先不管；

9. 现在考虑下我们是用CPU呢还是GPU呢，如果是使用CPU的话运行`pip install -r requirements.txt`，如果是使用GPU的话运行`pip install -r requirements-gpu.txt`，这个安装过程需要花点时间；

10. 安装FFMPEG，`brew install ffmpeg`即可；

11. 开始准备处理了，cd porn：

    - 对视频执行抽帧处理，`ffmpeg -i porn.mp4 -vf fps=30 "porn%d.png"`，抽帧图片会存放到porn目录下；
    - 回到上级目录；

12. 检查是否已经配置ok了，如果能弹出帮助菜单，则表示没有明显问题了，`python faceswap.py -h`，但是也可能提示各种module找不到的错误，这种情况下pip install对应的module就可以了；

    - pip install dlib，这个下载比较快，但是编译构建过程比较长，耐心等待下就好了，可能要十几分钟呢；

    > 如果这样还不行，也可以执行`conda install dlib`或者手动下载<http://dlib.net/files/dlib-19.9.tar.bz2>这个包，然后手动编译安装`python setup.py install`。

    - pip install opencv-python;

    > 安装完这个不一定就完全ok了，还可能缺这个少那个的，就pip install就可以了，也没什么好办法。

13. 现在对抽帧后的图片提取人脸，运行这里之前，可能要安装下人脸识别相关的模块：`python faceswap.py extract -i porn -o porn_faces`，读取porn下的抽帧照片并识别提取人脸，生成新的图片，存放到porn_faces下，比较花时间，建议视频短一点，1min左右；

14. 现在对期望替换成的图片提取人脸，`python faceswap.py extract -i jessica -o jessica_faces`，读取jessica目录下的图片并识别提取人脸，生成新的图片，存放到jessica_faces目录下，这里图片数量要精心挑选一下，但是识别出的faces照片数量至少要64张以上，才能正常跑后面的流程；

15. 好了，现在开始训练模型：`python faceswap.py train -A porn_faces -B jessica_faces -m model -p`，就是说训练一个模型，这个模型能够从A中的人脸图片进行适当运算后可以调整为B中的人脸，或者说这个运算函数就是这个模型，后面输入一个A中人脸的图片，就可以调整为B中的人脸了。模型训练完成后，会输出到model目录下。

    > 具体效果好不好，就要精细化调整一下了，比如A中的人脸都是侧着的，你提供的B中的人脸都是正着的，那这里训练处的模型也爱莫能助，效果很不好的。

16. 然后开始图片替换过程了，`python faceswap.py convert -i porn -o output -m model`，其实就是讲porn下的照片按照训练处的模型进行计算，从porn_faces调整为jessica_faces完成换脸；

17. 最终将换脸完成的照片，重新合称为视频即可，`ffmpeg -i porn%d.png -c:v libx264 -vf "fps=30,format=yuv420p" mysickfantasy.mp4`。

这里只是介绍一下如何完成视频换脸，这个程序应该说是非常好的介绍人工智能的应用了，AI is not porn，大家不要曲解AI的能力，这个应用也不是为了制造porn video，即便你只做出来了也不要传播到网络上，这个对相关人员是极其不负责任的行为，是不道德的，也是违法的！

上面的过程比较繁琐了，这里再简单整理下，适合已经了解整个处理过程的同学：

```
 1.  拷贝视频文件porn.mp4到faceswap/porn下，

 2.  开始抽帧：cd faceswap/porn && ffmpeg -i porn.mp4 -vf fps=30 "porn%d.png”

 3.  将网上精心收集的人脸照片放到faceswap/jessica目录下

 4.  开始进行人脸识别，并提取人脸区域的照片：

     - python faceswap.py extract -i porn -o porn_faces，视频抽帧人脸识别
     - python faceswap.py extract -i jessica -o jessica_faces，收集的人脸照片的人脸识别

	5. 开始训练模型，如何将视频中人脸替换成收集的明星的人脸，

    python faceswap.py train -A porn_faces -B jessica_faces -m model -p

6. 开始自行转换，转换视频中抽帧的图片中的人脸为明星的脸

   faceswap.py convert -i porn -o output -m model

7. 最后将替换完成的照片，重新合称为视频

   cd faceswap/porn && ffmpeg -i porn%d.png -c:v libx264 -vf "fps=30,format=yuv420p" mysickfantasy.mp4

```

好了，就总结到这里吧！用mbp来跑这个程序确实有点鸡肋，如果收集的图像质量不佳、数量过少也会影响到最终换脸的效果，希望下次买了带GPU卡的电脑后，再来测试一下吧！