package com.google.android.gms.common.api;

import com.google.android.gms.common.internal.InterfaceC0281d;
import com.google.android.gms.common.internal.InterfaceC0282e;
import com.google.android.gms.common.internal.InterfaceC0290m;
import java.util.Set;
import z0.C0773d;

/* JADX INFO: loaded from: classes.dex */
public interface g extends b {
    void connect(InterfaceC0281d interfaceC0281d);

    void disconnect();

    void disconnect(String str);

    C0773d[] getAvailableFeatures();

    String getEndpointPackageName();

    String getLastDisconnectMessage();

    int getMinApkVersion();

    void getRemoteService(InterfaceC0290m interfaceC0290m, Set set);

    Set getScopesForConnectionlessNonSignIn();

    boolean isConnected();

    boolean isConnecting();

    void onUserSignOut(InterfaceC0282e interfaceC0282e);

    boolean requiresGooglePlayServices();

    boolean requiresSignIn();
}
