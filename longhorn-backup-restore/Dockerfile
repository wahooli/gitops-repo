FROM python:slim-bullseye
ARG longhorn_py_url=https://raw.githubusercontent.com/longhorn/longhorn-tests/master/manager/integration/tests/longhorn.py
ARG user=python

RUN useradd -ms /bin/bash $user
RUN apt-get -qq update && apt-get -qq install --no-install-recommends -y \
    curl 

USER $user
WORKDIR /home/$user
ENV PATH="/home/${user}/.local/bin:${PATH}"

# setup venv and download longhorn.py
RUN pip install --upgrade pip && python3 -m venv backup-restore-env && \
    curl "${longhorn_py_url}" --output longhorn.py --silent

COPY requirements.txt .
RUN pip install -r requirements.txt

ENV LONGHORN_URL="http://longhorn-frontend.longhorn-system/v1"
# volume id or name
ENV VOLUME_HANDLE=""

ENV CREATE_PV="true"
ENV CREATE_PVC="true"
COPY longhorn_common.py .
COPY backup-restore.py .

ENTRYPOINT ["python3", "backup-restore.py"]