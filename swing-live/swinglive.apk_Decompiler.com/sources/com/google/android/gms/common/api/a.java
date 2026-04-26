package com.google.android.gms.common.api;

import android.content.Context;
import android.os.Looper;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.common.api.internal.InterfaceC0267o;
import com.google.android.gms.common.internal.C0285h;

/* JADX INFO: loaded from: classes.dex */
public abstract class a extends f {
    @Deprecated
    public g buildClient(Context context, Looper looper, C0285h c0285h, Object obj, m mVar, n nVar) {
        return buildClient(context, looper, c0285h, obj, (InterfaceC0258f) mVar, (InterfaceC0267o) nVar);
    }

    public g buildClient(Context context, Looper looper, C0285h c0285h, Object obj, InterfaceC0258f interfaceC0258f, InterfaceC0267o interfaceC0267o) {
        throw new UnsupportedOperationException("buildClient must be implemented");
    }
}
