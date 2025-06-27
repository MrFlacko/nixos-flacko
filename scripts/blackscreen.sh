#!/usr/bin/env bash
sleep 1 && \
dbus-send --session --print-reply \
  --dest=org.kde.kglobalaccel \
  /component/org_kde_powerdevil \
  org.kde.kglobalaccel.Component.invokeShortcut \
  string:'Turn Off Screen'