package F1;

import android.media.MediaCodec;
import android.media.MediaFormat;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;
import java.nio.ByteBuffer;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import y1.AbstractC0752b;

/* JADX INFO: loaded from: classes.dex */
public abstract class c {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public HandlerThread f421c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public ExecutorService f422d;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public MediaCodec f423f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public volatile long f424g;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public Handler f431n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public String f432o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public int f433p;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public String f419a = "BaseEncoder";

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final MediaCodec.BufferInfo f420b = new MediaCodec.BufferInfo();
    public ArrayBlockingQueue e = new ArrayBlockingQueue(80);

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public volatile boolean f425h = false;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public boolean f426i = true;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public final int f427j = 1;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public volatile long f428k = 0;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public boolean f429l = true;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public boolean f430m = false;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final e f434q = e.f438a;

    public abstract long a(d dVar, long j4);

    public abstract void b(ByteBuffer byteBuffer, MediaCodec.BufferInfo bufferInfo);

    public final void c(MediaCodec.BufferInfo bufferInfo) {
        if (this.f428k > bufferInfo.presentationTimeUs) {
            bufferInfo.presentationTimeUs = Math.max(AbstractC0752b.c() - this.f424g, this.f428k + 1);
        }
        this.f428k = bufferInfo.presentationTimeUs;
    }

    public abstract void d(MediaFormat mediaFormat);

    public final void e() {
        int iDequeueInputBuffer;
        if (!this.f432o.equals("audio/g711-alaw")) {
            if (this.f426i && (iDequeueInputBuffer = this.f423f.dequeueInputBuffer(0L)) >= 0) {
                h(this.f423f, iDequeueInputBuffer);
            }
            while (this.f425h) {
                int iDequeueOutputBuffer = this.f423f.dequeueOutputBuffer(this.f420b, 0L);
                if (iDequeueOutputBuffer == -2) {
                    d(this.f423f.getOutputFormat());
                } else {
                    if (iDequeueOutputBuffer < 0) {
                        return;
                    }
                    MediaCodec mediaCodec = this.f423f;
                    MediaCodec.BufferInfo bufferInfo = this.f420b;
                    ByteBuffer outputBuffer = mediaCodec.getOutputBuffer(iDequeueOutputBuffer);
                    b(outputBuffer, bufferInfo);
                    k(outputBuffer, bufferInfo);
                    mediaCodec.releaseOutputBuffer(iDequeueOutputBuffer, false);
                }
            }
            return;
        }
        try {
            d dVarF = f();
            while (dVarF == null) {
                dVarF = f();
            }
            byte[] bArrA = G1.b.a(dVarF.f435a, dVarF.f436b);
            ByteBuffer byteBufferWrap = ByteBuffer.wrap(bArrA, 0, bArrA.length);
            this.f420b.presentationTimeUs = a(dVarF, this.f424g);
            MediaCodec.BufferInfo bufferInfo2 = this.f420b;
            bufferInfo2.size = bArrA.length;
            bufferInfo2.offset = 0;
            k(byteBufferWrap, bufferInfo2);
        } catch (IndexOutOfBoundsException e) {
            e = e;
            Log.i(this.f419a, "Encoding error", e);
        } catch (InterruptedException unused) {
            Thread.currentThread().interrupt();
        } catch (NullPointerException e4) {
            e = e4;
            Log.i(this.f419a, "Encoding error", e);
        }
    }

    public abstract d f();

    public final void g() {
        if (!this.f432o.equals("audio/g711-alaw")) {
            this.f423f.start();
        }
        if (this.f432o.equals("audio/g711-alaw")) {
            ExecutorService executorServiceNewSingleThreadExecutor = Executors.newSingleThreadExecutor();
            this.f422d = executorServiceNewSingleThreadExecutor;
            executorServiceNewSingleThreadExecutor.submit(new a(this, 0));
        }
        this.f425h = true;
    }

    public final void h(MediaCodec mediaCodec, int i4) {
        ByteBuffer inputBuffer = mediaCodec.getInputBuffer(i4);
        try {
            d dVarF = f();
            while (dVarF == null) {
                dVarF = f();
            }
            inputBuffer.clear();
            int iMax = Math.max(0, Math.min(dVarF.f436b, inputBuffer.remaining()));
            inputBuffer.put(dVarF.f435a, 0, iMax);
            mediaCodec.queueInputBuffer(i4, 0, iMax, a(dVarF, this.f424g), 0);
        } catch (IndexOutOfBoundsException e) {
            e = e;
            Log.i(this.f419a, "Encoding error", e);
        } catch (InterruptedException unused) {
            Thread.currentThread().interrupt();
        } catch (NullPointerException e4) {
            e = e4;
            Log.i(this.f419a, "Encoding error", e);
        }
    }

    public final void i(IllegalStateException illegalStateException) {
        String str;
        if (illegalStateException instanceof MediaCodec.CodecException) {
            MediaCodec.CodecException codecException = (MediaCodec.CodecException) illegalStateException;
            if (codecException.isTransient()) {
                return;
            }
            if (codecException.isRecoverable()) {
                j();
                return;
            }
        }
        if (this.f429l) {
            int i4 = this.f433p;
            if (i4 == 1) {
                str = "VIDEO_CODEC";
            } else {
                if (i4 != 2) {
                    throw null;
                }
                str = "AUDIO_CODEC";
            }
            Log.e(str, "Encoder crashed, trying to recover it");
            j();
        }
    }

    public abstract boolean j();

    public abstract void k(ByteBuffer byteBuffer, MediaCodec.BufferInfo bufferInfo);

    public final void l() {
        if (this.f432o.equals("audio/g711-alaw")) {
            return;
        }
        HandlerThread handlerThread = new HandlerThread(this.f419a);
        this.f421c = handlerThread;
        handlerThread.start();
        this.f431n = new Handler(this.f421c.getLooper());
        this.f423f.setCallback(new b(this), this.f431n);
    }

    public final void m(long j4) {
        if (!this.f430m) {
            throw new IllegalStateException(this.f419a.concat(" not prepared yet. You must call prepare method before start it"));
        }
        this.f424g = j4;
        n(true);
        g();
    }

    public abstract void n(boolean z4);

    public final void o(boolean z4) {
        if (z4) {
            this.f424g = 0L;
        }
        this.f425h = false;
        p();
        HandlerThread handlerThread = this.f421c;
        if (handlerThread != null) {
            if (handlerThread.getLooper() != null) {
                if (this.f421c.getLooper().getThread() != null) {
                    this.f421c.getLooper().getThread().interrupt();
                }
                this.f421c.getLooper().quit();
            }
            this.f421c.quit();
            MediaCodec mediaCodec = this.f423f;
            if (mediaCodec != null) {
                try {
                    mediaCodec.flush();
                } catch (IllegalStateException unused) {
                }
            }
            try {
                this.f421c.getLooper().getThread().join(500L);
            } catch (Exception unused2) {
            }
        }
        ExecutorService executorService = this.f422d;
        if (executorService != null) {
            executorService.shutdownNow();
        }
        this.e.clear();
        this.e = new ArrayBlockingQueue(80);
        try {
            this.f423f.stop();
            this.f423f.release();
            this.f423f = null;
        } catch (IllegalStateException | NullPointerException unused3) {
            this.f423f = null;
        }
        this.f430m = false;
        this.f428k = 0L;
    }

    public abstract void p();
}
