package com.google.android.gms.common.api.internal;

import android.os.Looper;
import android.os.Message;
import android.util.Log;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.internal.base.zaq;

/* JADX INFO: loaded from: classes.dex */
public final class Q extends zaq {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ S f3434a;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public Q(S s4, Looper looper) {
        super(looper);
        this.f3434a = s4;
    }

    @Override // android.os.Handler
    public final void handleMessage(Message message) {
        int i4 = message.what;
        if (i4 != 0) {
            if (i4 == 1) {
                RuntimeException runtimeException = (RuntimeException) message.obj;
                String strValueOf = String.valueOf(runtimeException.getMessage());
                Log.e("TransformedResultImpl", strValueOf.length() != 0 ? "Runtime exception on the transformation worker thread: ".concat(strValueOf) : new String("Runtime exception on the transformation worker thread: "));
                throw runtimeException;
            }
            StringBuilder sb = new StringBuilder(70);
            sb.append("TransformationResultHandler received unknown message type: ");
            sb.append(i4);
            Log.e("TransformedResultImpl", sb.toString());
            return;
        }
        com.google.android.gms.common.api.q qVar = (com.google.android.gms.common.api.q) message.obj;
        synchronized (this.f3434a.f3436b) {
            try {
                S s4 = this.f3434a.f3435a;
                com.google.android.gms.common.internal.F.g(s4);
                if (qVar == null) {
                    s4.a(new Status(13, "Transform returned null"));
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
