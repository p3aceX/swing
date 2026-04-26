package F2;

import android.os.Build;
import android.os.Trace;
import android.util.Log;
import b0.AbstractC0242a;
import io.flutter.embedding.engine.FlutterJNI;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.List;
import java.util.WeakHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.atomic.AtomicBoolean;
import m3.AbstractC0554a;
import y0.C0747k;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class i implements O2.f, j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final FlutterJNI f464a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final HashMap f465b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final HashMap f466c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final Object f467d;
    public final AtomicBoolean e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final HashMap f468f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public int f469m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final k f470n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final WeakHashMap f471o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final C0779j f472p;

    public i(FlutterJNI flutterJNI) {
        C0779j c0779j = new C0779j(4);
        c0779j.f6969b = (ExecutorService) C0747k.N().f6833d;
        this.f465b = new HashMap();
        this.f466c = new HashMap();
        this.f467d = new Object();
        this.e = new AtomicBoolean(false);
        this.f468f = new HashMap();
        this.f469m = 1;
        this.f470n = new k();
        this.f471o = new WeakHashMap();
        this.f464a = flutterJNI;
        this.f472p = c0779j;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r0v2, types: [F2.c] */
    public final void a(final String str, final f fVar, final ByteBuffer byteBuffer, final int i4, final long j4) {
        e eVar = fVar != null ? fVar.f457b : null;
        String strA = AbstractC0554a.a("PlatformChannel ScheduleHandler on " + str);
        if (Build.VERSION.SDK_INT >= 29) {
            AbstractC0242a.a(i4, H0.a.h0(strA));
        } else {
            String strH0 = H0.a.h0(strA);
            try {
                if (H0.a.f513g == null) {
                    H0.a.f513g = Trace.class.getMethod("asyncTraceBegin", Long.TYPE, String.class, Integer.TYPE);
                }
                H0.a.f513g.invoke(null, Long.valueOf(H0.a.e), strH0, Integer.valueOf(i4));
            } catch (Exception e) {
                H0.a.H("asyncTraceBegin", e);
            }
        }
        ?? r02 = new Runnable() { // from class: F2.c
            @Override // java.lang.Runnable
            public final void run() {
                long j5 = j4;
                FlutterJNI flutterJNI = this.f448a.f464a;
                StringBuilder sb = new StringBuilder("PlatformChannel ScheduleHandler on ");
                String str2 = str;
                sb.append(str2);
                String strA2 = AbstractC0554a.a(sb.toString());
                int i5 = Build.VERSION.SDK_INT;
                int i6 = i4;
                if (i5 >= 29) {
                    AbstractC0242a.b(i6, H0.a.h0(strA2));
                } else {
                    String strH02 = H0.a.h0(strA2);
                    try {
                        if (H0.a.f514h == null) {
                            H0.a.f514h = Trace.class.getMethod("asyncTraceEnd", Long.TYPE, String.class, Integer.TYPE);
                        }
                        H0.a.f514h.invoke(null, Long.valueOf(H0.a.e), strH02, Integer.valueOf(i6));
                    } catch (Exception e4) {
                        H0.a.H("asyncTraceEnd", e4);
                    }
                }
                try {
                    AbstractC0554a.b("DartMessenger#handleMessageFromDart on " + str2);
                    f fVar2 = fVar;
                    ByteBuffer byteBuffer2 = byteBuffer;
                    try {
                        if (fVar2 != null) {
                            try {
                                try {
                                    fVar2.f456a.c(byteBuffer2, new g(flutterJNI, i6));
                                } catch (Exception e5) {
                                    Log.e("DartMessenger", "Uncaught exception in binary message listener", e5);
                                    flutterJNI.invokePlatformMessageEmptyResponseCallback(i6);
                                }
                            } catch (Error e6) {
                                Thread threadCurrentThread = Thread.currentThread();
                                if (threadCurrentThread.getUncaughtExceptionHandler() == null) {
                                    throw e6;
                                }
                                threadCurrentThread.getUncaughtExceptionHandler().uncaughtException(threadCurrentThread, e6);
                            }
                        } else {
                            flutterJNI.invokePlatformMessageEmptyResponseCallback(i6);
                        }
                        if (byteBuffer2 != null && byteBuffer2.isDirect()) {
                            byteBuffer2.limit(0);
                        }
                        Trace.endSection();
                    } finally {
                    }
                } finally {
                    flutterJNI.cleanupMessageData(j5);
                }
            }
        };
        e eVar2 = eVar;
        if (eVar == null) {
            eVar2 = this.f470n;
        }
        eVar2.a(r02);
    }

    @Override // O2.f
    public final void b(String str, O2.d dVar, p1.d dVar2) {
        e eVar;
        if (dVar == null) {
            synchronized (this.f467d) {
                this.f465b.remove(str);
            }
            return;
        }
        if (dVar2 != null) {
            eVar = (e) this.f471o.get(dVar2);
            if (eVar == null) {
                throw new IllegalArgumentException("Unrecognized TaskQueue, use BinaryMessenger to create your TaskQueue (ex makeBackgroundTaskQueue).");
            }
        } else {
            eVar = null;
        }
        synchronized (this.f467d) {
            try {
                this.f465b.put(str, new f(dVar, eVar));
                List<d> list = (List) this.f466c.remove(str);
                if (list == null) {
                    return;
                }
                for (d dVar3 : list) {
                    a(str, (f) this.f465b.get(str), dVar3.f453a, dVar3.f454b, dVar3.f455c);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    @Override // O2.f
    public final void i(String str, ByteBuffer byteBuffer) {
        s(str, byteBuffer, null);
    }

    @Override // O2.f
    public final p1.d m(O2.k kVar) {
        C0779j c0779j = this.f472p;
        c0779j.getClass();
        h hVar = new h((ExecutorService) c0779j.f6969b);
        p1.d dVar = new p1.d(2);
        this.f471o.put(dVar, hVar);
        return dVar;
    }

    @Override // O2.f
    public final void p(String str, O2.d dVar) {
        b(str, dVar, null);
    }

    @Override // O2.f
    public final void s(String str, ByteBuffer byteBuffer, O2.e eVar) {
        AbstractC0554a.b("DartMessenger#send on " + str);
        try {
            int i4 = this.f469m;
            this.f469m = i4 + 1;
            if (eVar != null) {
                this.f468f.put(Integer.valueOf(i4), eVar);
            }
            FlutterJNI flutterJNI = this.f464a;
            if (byteBuffer == null) {
                flutterJNI.dispatchEmptyPlatformMessage(str, i4);
            } else {
                flutterJNI.dispatchPlatformMessage(str, byteBuffer, byteBuffer.position(), i4);
            }
            Trace.endSection();
        } catch (Throwable th) {
            try {
                Trace.endSection();
            } catch (Throwable th2) {
                th.addSuppressed(th2);
            }
            throw th;
        }
    }
}
