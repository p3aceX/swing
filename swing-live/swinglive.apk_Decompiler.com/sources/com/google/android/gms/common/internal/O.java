package com.google.android.gms.common.internal;

import android.content.ComponentName;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public final class O implements Handler.Callback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ P f3544a;

    public /* synthetic */ O(P p4) {
        this.f3544a = p4;
    }

    @Override // android.os.Handler.Callback
    public final boolean handleMessage(Message message) {
        int i4 = message.what;
        if (i4 == 0) {
            synchronized (this.f3544a.f3545d) {
                try {
                    M m4 = (M) message.obj;
                    N n4 = (N) this.f3544a.f3545d.get(m4);
                    if (n4 != null && n4.f3538a.isEmpty()) {
                        if (n4.f3540c) {
                            n4.f3543g.f3546f.removeMessages(1, n4.e);
                            P p4 = n4.f3543g;
                            p4.f3547g.a(p4.e, n4);
                            n4.f3540c = false;
                            n4.f3539b = 2;
                        }
                        this.f3544a.f3545d.remove(m4);
                    }
                } finally {
                }
            }
            return true;
        }
        if (i4 != 1) {
            return false;
        }
        synchronized (this.f3544a.f3545d) {
            try {
                M m5 = (M) message.obj;
                N n5 = (N) this.f3544a.f3545d.get(m5);
                if (n5 != null && n5.f3539b == 3) {
                    Log.e("GmsClientSupervisor", "Timeout waiting for ServiceConnection callback ".concat(String.valueOf(m5)), new Exception());
                    ComponentName componentName = n5.f3542f;
                    if (componentName == null) {
                        componentName = m5.f3536c;
                    }
                    if (componentName == null) {
                        String str = m5.f3535b;
                        F.g(str);
                        componentName = new ComponentName(str, "unknown");
                    }
                    n5.onServiceDisconnected(componentName);
                }
            } finally {
            }
        }
        return true;
    }
}
