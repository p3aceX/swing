package w1;

import D2.v;
import N2.j;
import O2.f;
import O2.m;
import T2.r;
import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import java.util.HashMap;
import java.util.Map;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public class c implements m, K2.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public C0747k f6706a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public C0702a f6707b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public HandlerThread f6708c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public Handler f6709d;

    public static String a(c cVar, v vVar) {
        cVar.getClass();
        Map map = (Map) vVar.f261c;
        C0702a c0702a = cVar.f6707b;
        return c0702a.f6696c + "_" + ((String) map.get("key"));
    }

    @Override // K2.a
    public final void c(C0747k c0747k) {
        f fVar = (f) c0747k.f6832c;
        try {
            this.f6707b = new C0702a((Context) c0747k.f6831b, new HashMap());
            HandlerThread handlerThread = new HandlerThread("com.it_nomads.fluttersecurestorage.worker");
            this.f6708c = handlerThread;
            handlerThread.start();
            this.f6709d = new Handler(this.f6708c.getLooper());
            C0747k c0747k2 = new C0747k(fVar, "plugins.it_nomads.com/flutter_secure_storage", 11);
            this.f6706a = c0747k2;
            c0747k2.Y(this);
        } catch (Exception e) {
            Log.e("FlutterSecureStoragePl", "Registration failed", e);
        }
    }

    @Override // O2.m
    public final void g(v vVar, j jVar) {
        this.f6709d.post(new r(this, vVar, new j(jVar), 3));
    }

    @Override // K2.a
    public final void m(C0747k c0747k) {
        if (this.f6706a != null) {
            this.f6708c.quitSafely();
            this.f6708c = null;
            this.f6706a.Y(null);
            this.f6706a = null;
        }
        this.f6707b = null;
    }
}
