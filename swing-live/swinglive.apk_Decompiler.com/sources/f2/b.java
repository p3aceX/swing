package F2;

import android.content.res.AssetManager;
import android.os.Trace;
import android.util.Log;
import io.flutter.embedding.engine.FlutterJNI;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.Objects;
import m3.AbstractC0554a;
import u1.C0690c;

/* JADX INFO: loaded from: classes.dex */
public final class b implements O2.f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final FlutterJNI f443a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AssetManager f444b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final long f445c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final i f446d;
    public final C0690c e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public boolean f447f;

    public b(FlutterJNI flutterJNI, AssetManager assetManager, long j4) {
        this.f447f = false;
        B.k kVar = new B.k((Object) this, 3);
        this.f443a = flutterJNI;
        this.f444b = assetManager;
        this.f445c = j4;
        i iVar = new i(flutterJNI);
        this.f446d = iVar;
        iVar.b("flutter/isolate", kVar, null);
        this.e = new C0690c(iVar, 4);
        if (flutterJNI.isAttached()) {
            this.f447f = true;
        }
    }

    public final void a(a aVar, List list) {
        if (this.f447f) {
            Log.w("DartExecutor", "Attempted to run a DartExecutor that is already running.");
            return;
        }
        AbstractC0554a.b("DartExecutor#executeDartEntrypoint");
        try {
            Objects.toString(aVar);
            this.f443a.runBundleAndSnapshotFromLibrary(aVar.f440a, aVar.f442c, aVar.f441b, this.f444b, list, this.f445c);
            this.f447f = true;
            Trace.endSection();
        } finally {
        }
    }

    @Override // O2.f
    public final void b(String str, O2.d dVar, p1.d dVar2) {
        this.e.b(str, dVar, dVar2);
    }

    @Override // O2.f
    public final void i(String str, ByteBuffer byteBuffer) {
        this.e.i(str, byteBuffer);
    }

    @Override // O2.f
    public final p1.d m(O2.k kVar) {
        return ((i) this.e.f6642b).m(kVar);
    }

    @Override // O2.f
    public final void p(String str, O2.d dVar) {
        this.e.p(str, dVar);
    }

    @Override // O2.f
    public final void s(String str, ByteBuffer byteBuffer, O2.e eVar) {
        this.e.s(str, byteBuffer, eVar);
    }
}
