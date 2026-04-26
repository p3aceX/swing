package io.flutter.embedding.engine.renderer;

import D2.C0030e;
import android.graphics.SurfaceTexture;
import android.os.Build;
import android.os.Handler;
import android.view.Surface;
import io.flutter.embedding.engine.FlutterJNI;
import io.flutter.view.TextureRegistry$ImageTextureEntry;
import io.flutter.view.TextureRegistry$SurfaceProducer;
import io.flutter.view.r;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicLong;

/* JADX INFO: loaded from: classes.dex */
public final class j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final FlutterJNI f4535a;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public Surface f4537c;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final C0030e f4541h;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final AtomicLong f4536b = new AtomicLong(0);

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f4538d = false;
    public final Handler e = new Handler();

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final HashSet f4539f = new HashSet();

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final ArrayList f4540g = new ArrayList();

    public j(FlutterJNI flutterJNI) {
        C0030e c0030e = new C0030e(this, 3);
        this.f4541h = c0030e;
        this.f4535a = flutterJNI;
        flutterJNI.addIsDisplayingFlutterUiListener(c0030e);
    }

    public final void a(k kVar) {
        this.f4535a.addIsDisplayingFlutterUiListener(kVar);
        if (this.f4538d) {
            kVar.b();
        }
    }

    public final void b(r rVar) {
        HashSet hashSet = this.f4539f;
        Iterator it = hashSet.iterator();
        while (it.hasNext()) {
            if (((r) ((WeakReference) it.next()).get()) == null) {
                it.remove();
            }
        }
        hashSet.add(new WeakReference(rVar));
    }

    public final TextureRegistry$ImageTextureEntry c() {
        FlutterRenderer$ImageTextureRegistryEntry flutterRenderer$ImageTextureRegistryEntry = new FlutterRenderer$ImageTextureRegistryEntry(this, this.f4536b.getAndIncrement());
        flutterRenderer$ImageTextureRegistryEntry.id();
        this.f4535a.registerImageTexture(flutterRenderer$ImageTextureRegistryEntry.id(), flutterRenderer$ImageTextureRegistryEntry, false);
        return flutterRenderer$ImageTextureRegistryEntry;
    }

    public final TextureRegistry$SurfaceProducer d(int i4) {
        if (Build.VERSION.SDK_INT < 29) {
            g gVarE = e();
            return new n(gVarE.f4509a, this.e, this.f4535a, gVarE);
        }
        long andIncrement = this.f4536b.getAndIncrement();
        FlutterRenderer$ImageReaderSurfaceProducer flutterRenderer$ImageReaderSurfaceProducer = new FlutterRenderer$ImageReaderSurfaceProducer(this, andIncrement);
        boolean z4 = i4 == 2;
        this.f4535a.registerImageTexture(andIncrement, flutterRenderer$ImageReaderSurfaceProducer, z4);
        if (z4) {
            b(flutterRenderer$ImageReaderSurfaceProducer);
        }
        this.f4540g.add(flutterRenderer$ImageReaderSurfaceProducer);
        return flutterRenderer$ImageReaderSurfaceProducer;
    }

    public final g e() {
        SurfaceTexture surfaceTexture = new SurfaceTexture(0);
        long andIncrement = this.f4536b.getAndIncrement();
        surfaceTexture.detachFromGLContext();
        g gVar = new g(this, andIncrement, surfaceTexture);
        this.f4535a.registerTexture(gVar.f4509a, gVar.f4510b);
        b(gVar);
        return gVar;
    }

    public final void f(int i4) {
        Iterator it = this.f4539f.iterator();
        while (it.hasNext()) {
            r rVar = (r) ((WeakReference) it.next()).get();
            if (rVar != null) {
                rVar.onTrimMemory(i4);
            } else {
                it.remove();
            }
        }
    }

    public final void g(k kVar) {
        this.f4535a.removeIsDisplayingFlutterUiListener(kVar);
    }

    public final void h(r rVar) {
        HashSet<WeakReference> hashSet = this.f4539f;
        for (WeakReference weakReference : hashSet) {
            if (weakReference.get() == rVar) {
                hashSet.remove(weakReference);
                return;
            }
        }
    }

    public final void i() {
        Iterator it = this.f4540g.iterator();
        while (it.hasNext()) {
            ((FlutterRenderer$ImageReaderSurfaceProducer) it.next()).getClass();
        }
    }

    public final void j() {
        if (this.f4537c != null) {
            this.f4535a.onSurfaceDestroyed();
            if (this.f4538d) {
                this.f4541h.a();
            }
            this.f4538d = false;
            this.f4537c = null;
        }
    }
}
