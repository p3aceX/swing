package com.google.android.gms.common.internal;

import android.app.PendingIntent;
import android.os.Bundle;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import com.google.android.gms.common.api.internal.InterfaceC0258f;
import com.google.android.gms.internal.common.zzi;
import z0.C0771b;

/* JADX INFO: loaded from: classes.dex */
public final class G extends zzi {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ AbstractC0283f f3522a;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public G(AbstractC0283f abstractC0283f, Looper looper) {
        super(looper);
        this.f3522a = abstractC0283f;
    }

    @Override // android.os.Handler
    public final void handleMessage(Message message) {
        Boolean bool;
        if (this.f3522a.zzd.get() != message.arg1) {
            int i4 = message.what;
            if (i4 == 2 || i4 == 1 || i4 == 7) {
                C c5 = (C) message.obj;
                c5.getClass();
                c5.c();
                return;
            }
            return;
        }
        int i5 = message.what;
        if ((i5 == 1 || i5 == 7 || ((i5 == 4 && !this.f3522a.enableLocalFallback()) || message.what == 5)) && !this.f3522a.isConnecting()) {
            C c6 = (C) message.obj;
            c6.getClass();
            c6.c();
            return;
        }
        int i6 = message.what;
        if (i6 == 4) {
            this.f3522a.zzB = new C0771b(message.arg2);
            if (AbstractC0283f.zzo(this.f3522a)) {
                AbstractC0283f abstractC0283f = this.f3522a;
                if (!abstractC0283f.zzC) {
                    abstractC0283f.a(3, null);
                    return;
                }
            }
            AbstractC0283f abstractC0283f2 = this.f3522a;
            C0771b c0771b = abstractC0283f2.zzB != null ? abstractC0283f2.zzB : new C0771b(8);
            this.f3522a.zzc.a(c0771b);
            this.f3522a.onConnectionFailed(c0771b);
            return;
        }
        if (i6 == 5) {
            AbstractC0283f abstractC0283f3 = this.f3522a;
            C0771b c0771b2 = abstractC0283f3.zzB != null ? abstractC0283f3.zzB : new C0771b(8);
            this.f3522a.zzc.a(c0771b2);
            this.f3522a.onConnectionFailed(c0771b2);
            return;
        }
        if (i6 == 3) {
            Object obj = message.obj;
            C0771b c0771b3 = new C0771b(message.arg2, obj instanceof PendingIntent ? (PendingIntent) obj : null);
            this.f3522a.zzc.a(c0771b3);
            this.f3522a.onConnectionFailed(c0771b3);
            return;
        }
        if (i6 == 6) {
            this.f3522a.a(5, null);
            AbstractC0283f abstractC0283f4 = this.f3522a;
            if (abstractC0283f4.zzw != null) {
                ((InterfaceC0258f) ((t) abstractC0283f4.zzw).f3601a).c(message.arg2);
            }
            this.f3522a.onConnectionSuspended(message.arg2);
            AbstractC0283f.zzn(this.f3522a, 5, 1, null);
            return;
        }
        if (i6 == 2 && !this.f3522a.isConnected()) {
            C c7 = (C) message.obj;
            c7.getClass();
            c7.c();
            return;
        }
        int i7 = message.what;
        if (i7 != 2 && i7 != 1 && i7 != 7) {
            Log.wtf("GmsClient", com.google.crypto.tink.shaded.protobuf.S.d(i7, "Don't know how to handle message: "), new Exception());
            return;
        }
        C c8 = (C) message.obj;
        synchronized (c8) {
            try {
                bool = c8.f3513a;
                if (c8.f3514b) {
                    Log.w("GmsClient", "Callback proxy " + c8.toString() + " being reused. This is not safe.");
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        if (bool != null) {
            AbstractC0283f abstractC0283f5 = c8.f3517f;
            int i8 = c8.f3516d;
            if (i8 != 0) {
                abstractC0283f5.a(1, null);
                Bundle bundle = c8.e;
                c8.a(new C0771b(i8, bundle != null ? (PendingIntent) bundle.getParcelable(AbstractC0283f.KEY_PENDING_INTENT) : null));
            } else if (!c8.b()) {
                abstractC0283f5.a(1, null);
                c8.a(new C0771b(8, null));
            }
        }
        synchronized (c8) {
            c8.f3514b = true;
        }
        c8.c();
    }
}
