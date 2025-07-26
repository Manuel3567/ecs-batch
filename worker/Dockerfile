FROM public.ecr.aws/docker/library/python:3.13-bullseye
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD python main.py