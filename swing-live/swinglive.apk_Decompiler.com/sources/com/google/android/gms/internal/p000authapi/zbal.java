package com.google.android.gms.internal.p000authapi;

import android.content.Context;
import android.os.Looper;
import com.google.android.gms.common.api.a;
import com.google.android.gms.common.api.g;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.common.api.internal.InterfaceC0267o;
import com.google.android.gms.common.internal.C0285h;

/* JADX INFO: loaded from: classes.dex */
final class zbal extends a {
    @Override // com.google.android.gms.common.api.a
    public final /* synthetic */ g buildClient(Context context, Looper looper, C0285h c0285h, Object obj, InterfaceC0258f interfaceC0258f, InterfaceC0267o interfaceC0267o) {
        if (obj == null) {
            return new zbar(context, looper, null, c0285h, interfaceC0258f, interfaceC0267o);
        }
        throw new ClassCastException();
    }
}
