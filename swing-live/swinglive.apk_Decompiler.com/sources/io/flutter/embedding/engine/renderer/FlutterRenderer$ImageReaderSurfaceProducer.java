package io.flutter.embedding.engine.renderer;

import android.media.Image;
import android.media.ImageReader;
import android.os.Build;
import android.view.Surface;
import androidx.annotation.Keep;
import io.flutter.view.TextureRegistry$ImageConsumer;
import io.flutter.view.TextureRegistry$SurfaceProducer;
import io.flutter.view.r;
import io.flutter.view.s;
import java.io.IOException;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
@Keep
final class FlutterRenderer$ImageReaderSurfaceProducer implements TextureRegistry$SurfaceProducer, TextureRegistry$ImageConsumer, r {
    private static final boolean CLEANUP_ON_MEMORY_PRESSURE = true;
    private static final int MAX_DEQUEUED_IMAGES = 2;
    private static final int MAX_IMAGES = 7;
    private static final String TAG = "ImageReaderSurfaceProducer";
    private static final boolean VERBOSE_LOGS = false;
    private static final boolean trimOnMemoryPressure = true;
    s callback;
    private final long id;
    private boolean released;
    final /* synthetic */ j this$0;
    private boolean ignoringFence = VERBOSE_LOGS;
    private int requestedWidth = 1;
    private int requestedHeight = 1;
    private boolean createNewReader = true;
    boolean notifiedDestroy = VERBOSE_LOGS;
    private long lastDequeueTime = 0;
    private long lastQueueTime = 0;
    private long lastScheduleTime = 0;
    private int numTrims = 0;
    private final Object lock = new Object();
    private final ArrayDeque<e> imageReaderQueue = new ArrayDeque<>();
    private final HashMap<ImageReader, e> perImageReaders = new HashMap<>();
    private ArrayList<c> lastDequeuedImage = new ArrayList<>();
    private e lastReaderDequeuedFrom = null;

    public FlutterRenderer$ImageReaderSurfaceProducer(j jVar, long j4) {
        this.this$0 = jVar;
        this.id = j4;
    }

    private void cleanup() {
        synchronized (this.lock) {
            try {
                for (e eVar : this.perImageReaders.values()) {
                    if (this.lastReaderDequeuedFrom == eVar) {
                        this.lastReaderDequeuedFrom = null;
                    }
                    eVar.f4506c = true;
                    eVar.f4504a.close();
                    eVar.f4505b.clear();
                }
                this.perImageReaders.clear();
                if (this.lastDequeuedImage.size() > 0) {
                    Iterator<c> it = this.lastDequeuedImage.iterator();
                    while (it.hasNext()) {
                        it.next().f4501a.close();
                    }
                    this.lastDequeuedImage.clear();
                }
                e eVar2 = this.lastReaderDequeuedFrom;
                if (eVar2 != null) {
                    eVar2.f4506c = true;
                    eVar2.f4504a.close();
                    eVar2.f4505b.clear();
                    this.lastReaderDequeuedFrom = null;
                }
                this.imageReaderQueue.clear();
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    private ImageReader createImageReader29() {
        return ImageReader.newInstance(this.requestedWidth, this.requestedHeight, 34, 7, 256L);
    }

    private ImageReader createImageReader33() {
        B.c.n();
        ImageReader.Builder builderG = B.c.g(this.requestedWidth, this.requestedHeight);
        builderG.setMaxImages(7);
        builderG.setImageFormat(34);
        builderG.setUsage(256L);
        return builderG.build();
    }

    private e getActiveReader() {
        synchronized (this.lock) {
            try {
                if (!this.createNewReader) {
                    e eVarPeekLast = this.imageReaderQueue.peekLast();
                    if (eVarPeekLast.f4504a.getSurface().isValid()) {
                        return eVarPeekLast;
                    }
                }
                this.createNewReader = VERBOSE_LOGS;
                return getOrCreatePerImageReader(createImageReader());
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    private e getOrCreatePerImageReader(ImageReader imageReader) {
        e eVar = this.perImageReaders.get(imageReader);
        if (eVar != null) {
            return eVar;
        }
        e eVarCreatePerImageReader = createPerImageReader(imageReader);
        this.perImageReaders.put(imageReader, eVarCreatePerImageReader);
        this.imageReaderQueue.add(eVarCreatePerImageReader);
        return eVarCreatePerImageReader;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void lambda$dequeueImage$0() {
        if (this.released) {
            return;
        }
        this.this$0.f4535a.scheduleFrame();
    }

    private void maybeWaitOnFence(Image image) {
        if (image == null || this.ignoringFence) {
            return;
        }
        if (Build.VERSION.SDK_INT >= 33) {
            waitOnFence(image);
        } else {
            this.ignoringFence = true;
        }
    }

    private void releaseInternal() {
        cleanup();
        this.released = true;
        this.this$0.h(this);
        this.this$0.f4540g.remove(this);
    }

    private void waitOnFence(Image image) {
        try {
            image.getFence().awaitForever();
        } catch (IOException unused) {
        }
    }

    @Override // io.flutter.view.TextureRegistry$ImageConsumer
    public Image acquireLatestImage() {
        c cVarDequeueImage = dequeueImage();
        if (cVarDequeueImage == null) {
            return null;
        }
        Image image = cVarDequeueImage.f4501a;
        maybeWaitOnFence(image);
        return image;
    }

    public ImageReader createImageReader() {
        int i4 = Build.VERSION.SDK_INT;
        if (i4 >= 33) {
            return createImageReader33();
        }
        if (i4 >= 29) {
            return createImageReader29();
        }
        throw new UnsupportedOperationException("ImageReaderPlatformViewRenderTarget requires API version 29+");
    }

    public e createPerImageReader(ImageReader imageReader) {
        return new e(this, imageReader);
    }

    public double deltaMillis(long j4) {
        return j4 / 1000000.0d;
    }

    public c dequeueImage() {
        c cVar;
        boolean z4;
        synchronized (this.lock) {
            try {
                Iterator<e> it = this.imageReaderQueue.iterator();
                cVar = null;
                while (true) {
                    boolean zHasNext = it.hasNext();
                    z4 = VERBOSE_LOGS;
                    if (!zHasNext) {
                        break;
                    }
                    e next = it.next();
                    ArrayDeque arrayDeque = next.f4505b;
                    c cVar2 = arrayDeque.isEmpty() ? null : (c) arrayDeque.removeFirst();
                    if (cVar2 == null) {
                        cVar = cVar2;
                    } else {
                        while (this.lastDequeuedImage.size() > 2) {
                            this.lastDequeuedImage.remove(0).f4501a.close();
                        }
                        this.lastDequeuedImage.add(cVar2);
                        this.lastReaderDequeuedFrom = next;
                        cVar = cVar2;
                    }
                }
                pruneImageReaderQueue();
                Iterator<e> it2 = this.imageReaderQueue.iterator();
                while (true) {
                    if (!it2.hasNext()) {
                        break;
                    }
                    if (!it2.next().f4505b.isEmpty()) {
                        z4 = true;
                        break;
                    }
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        if (z4) {
            this.this$0.e.post(new b(this, 0));
        }
        return cVar;
    }

    public void disableFenceForTest() {
        this.ignoringFence = true;
    }

    public void finalize() throws Throwable {
        try {
            if (this.released) {
                return;
            }
            releaseInternal();
            j jVar = this.this$0;
            jVar.e.post(new h(this.id, jVar.f4535a));
        } finally {
            super.finalize();
        }
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public Surface getForcedNewSurface() {
        this.createNewReader = true;
        return getSurface();
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public int getHeight() {
        return this.requestedHeight;
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public Surface getSurface() {
        return getActiveReader().f4504a.getSurface();
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public int getWidth() {
        return this.requestedWidth;
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public boolean handlesCropAndRotation() {
        return VERBOSE_LOGS;
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public long id() {
        return this.id;
    }

    public int numImageReaders() {
        int size;
        synchronized (this.lock) {
            size = this.imageReaderQueue.size();
        }
        return size;
    }

    public int numImages() {
        int size;
        synchronized (this.lock) {
            try {
                Iterator<e> it = this.imageReaderQueue.iterator();
                size = 0;
                while (it.hasNext()) {
                    size += it.next().f4505b.size();
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        return size;
    }

    public int numTrims() {
        int i4;
        synchronized (this.lock) {
            i4 = this.numTrims;
        }
        return i4;
    }

    public void onImage(ImageReader imageReader, Image image) {
        c cVar;
        synchronized (this.lock) {
            e orCreatePerImageReader = getOrCreatePerImageReader(imageReader);
            if (orCreatePerImageReader.f4506c) {
                cVar = null;
            } else {
                FlutterRenderer$ImageReaderSurfaceProducer flutterRenderer$ImageReaderSurfaceProducer = orCreatePerImageReader.f4507d;
                System.nanoTime();
                c cVar2 = new c(flutterRenderer$ImageReaderSurfaceProducer, image);
                ArrayDeque arrayDeque = orCreatePerImageReader.f4505b;
                arrayDeque.add(cVar2);
                while (arrayDeque.size() > 2) {
                    ((c) arrayDeque.removeFirst()).f4501a.close();
                }
                cVar = cVar2;
            }
        }
        if (cVar == null) {
            return;
        }
        this.this$0.f4535a.scheduleFrame();
    }

    @Override // io.flutter.view.r
    public void onTrimMemory(int i4) {
        if (i4 < 40) {
            return;
        }
        synchronized (this.lock) {
            this.numTrims++;
        }
        cleanup();
        this.createNewReader = true;
    }

    public int pendingDequeuedImages() {
        return this.lastDequeuedImage.size();
    }

    public void pruneImageReaderQueue() {
        e eVarPeekFirst;
        while (this.imageReaderQueue.size() > 1 && (eVarPeekFirst = this.imageReaderQueue.peekFirst()) != null) {
            ArrayDeque arrayDeque = eVarPeekFirst.f4505b;
            if (!arrayDeque.isEmpty() || eVarPeekFirst.f4507d.lastReaderDequeuedFrom == eVarPeekFirst) {
                return;
            }
            this.imageReaderQueue.removeFirst();
            HashMap<ImageReader, e> map = this.perImageReaders;
            ImageReader imageReader = eVarPeekFirst.f4504a;
            map.remove(imageReader);
            eVarPeekFirst.f4506c = true;
            imageReader.close();
            arrayDeque.clear();
        }
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public void release() {
        if (this.released) {
            return;
        }
        releaseInternal();
        j jVar = this.this$0;
        jVar.f4535a.unregisterTexture(this.id);
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public void scheduleFrame() {
        this.this$0.f4535a.scheduleFrame();
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public void setCallback(s sVar) {
    }

    @Override // io.flutter.view.TextureRegistry$SurfaceProducer
    public void setSize(int i4, int i5) {
        int iMax = Math.max(1, i4);
        int iMax2 = Math.max(1, i5);
        if (this.requestedWidth == iMax && this.requestedHeight == iMax2) {
            return;
        }
        this.createNewReader = true;
        this.requestedHeight = iMax2;
        this.requestedWidth = iMax;
    }
}
