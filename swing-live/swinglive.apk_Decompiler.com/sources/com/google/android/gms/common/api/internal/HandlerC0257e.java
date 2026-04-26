package com.google.android.gms.common.api.internal;

import android.os.Message;
import android.util.Log;
import android.util.Pair;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.internal.base.zaq;

/* JADX INFO: renamed from: com.google.android.gms.common.api.internal.e, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class HandlerC0257e extends zaq {
    public final void a(com.google.android.gms.common.api.t tVar, com.google.android.gms.common.api.s sVar) {
        int i4 = BasePendingResult.zad;
        com.google.android.gms.common.internal.F.g(tVar);
        sendMessage(obtainMessage(1, new Pair(tVar, sVar)));
    }

    @Override // android.os.Handler
    public final void handleMessage(Message message) {
        int i4 = message.what;
        if (i4 != 1) {
            if (i4 == 2) {
                ((BasePendingResult) message.obj).forceFailureUnlessReady(Status.f3375o);
                return;
            }
            StringBuilder sb = new StringBuilder(45);
            sb.append("Don't know how to handle message: ");
            sb.append(i4);
            Log.wtf("BasePendingResult", sb.toString(), new Exception());
            return;
        }
        Pair pair = (Pair) message.obj;
        com.google.android.gms.common.api.t tVar = (com.google.android.gms.common.api.t) pair.first;
        com.google.android.gms.common.api.s sVar = (com.google.android.gms.common.api.s) pair.second;
        try {
            S s4 = (S) tVar;
            synchronized (s4.f3436b) {
                if (sVar.getStatus().b()) {
                } else {
                    s4.a(sVar.getStatus());
                }
            }
        } catch (RuntimeException e) {
            BasePendingResult.zal(sVar);
            throw e;
        }
    }
}
