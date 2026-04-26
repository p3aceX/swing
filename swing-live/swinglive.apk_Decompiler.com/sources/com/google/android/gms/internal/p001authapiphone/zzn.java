package com.google.android.gms.internal.p001authapiphone;

import android.content.Context;
import android.os.Looper;
import com.google.android.gms.common.api.a;
import com.google.android.gms.common.api.g;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.common.api.internal.InterfaceC0267o;
import com.google.android.gms.common.internal.C0285h;

/* JADX INFO: loaded from: classes.dex */
final class zzn extends a {
    @Override // com.google.android.gms.common.api.a
    public final /* synthetic */ g buildClient(Context context, Looper looper, C0285h c0285h, Object obj, InterfaceC0258f interfaceC0258f, InterfaceC0267o interfaceC0267o) {
        return new zzw(context, looper, c0285h, interfaceC0258f, interfaceC0267o);
    }
}
