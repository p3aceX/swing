package G1;

import F1.c;
import F1.d;
import F1.e;
import J3.i;
import android.media.MediaCodec;
import android.media.MediaCodecInfo;
import android.media.MediaCrypto;
import android.media.MediaFormat;
import android.util.Log;
import android.view.Surface;
import e2.L;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import r2.r;
import y1.AbstractC0752b;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class a extends c {

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public final C0779j f492r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public int f493s = 65536;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public int f494t = 32000;

    /* JADX INFO: renamed from: u, reason: collision with root package name */
    public boolean f495u = true;
    public long v = 0;

    public a(C0779j c0779j) {
        this.f492r = c0779j;
        this.f433p = 2;
        this.f432o = "audio/mp4a-latm";
        this.f419a = "AudioEncoder";
    }

    @Override // F1.c
    public final long a(d dVar, long j4) {
        long jMax = Math.max(0L, dVar.f437c - j4);
        if (this.f434q == e.f438a) {
            return jMax;
        }
        if (this.v == 0) {
            this.v = jMax;
        }
        long j5 = (((long) (((double) dVar.f436b) / (((long) (this.f494t * (this.f495u ? 2 : 1))) * 2))) * 1000000) + this.v;
        this.v = j5;
        if (jMax - j5 > 500000) {
            this.v = jMax;
        }
        return this.v;
    }

    @Override // F1.c
    public final void b(ByteBuffer byteBuffer, MediaCodec.BufferInfo bufferInfo) {
        c(bufferInfo);
    }

    @Override // F1.c
    public final void d(MediaFormat mediaFormat) {
        U1.a aVar = ((S1.a) this.f492r.f6969b).f1804k;
        aVar.f2095h = mediaFormat;
        int i4 = aVar.f2093f;
        if (i4 == 3 && aVar.f2089a == 1) {
            if (i4 == 2) {
                throw null;
            }
            throw null;
        }
    }

    @Override // F1.c
    public final d f() {
        return (d) this.e.take();
    }

    @Override // F1.c
    public final boolean j() {
        o(false);
        if (!r(this.f493s, this.f494t, this.f495u)) {
            return false;
        }
        n(false);
        g();
        return true;
    }

    @Override // F1.c
    public final void k(ByteBuffer byteBuffer, MediaCodec.BufferInfo bufferInfo) {
        S1.a aVar = (S1.a) this.f492r.f6969b;
        U1.a aVar2 = aVar.f1804k;
        if (aVar2.f2089a == 3 && aVar2.f2093f != 2) {
            aVar2.d(aVar2.f2092d, bufferInfo);
        }
        if (aVar.f1799f) {
            switch (aVar.f1808o) {
                case 0:
                    i.e(byteBuffer, "audioBuffer");
                    i.e(bufferInfo, "info");
                    L l2 = (L) aVar.f1809p;
                    if (l2 == null) {
                        i.g("rtmpClient");
                        throw null;
                    }
                    l2.f4053g.getClass();
                    l2.f4054h.b(new B1.d(AbstractC0752b.a(byteBuffer), AbstractC0752b.m(bufferInfo), B1.c.f113b));
                    return;
                default:
                    i.e(byteBuffer, "audioBuffer");
                    i.e(bufferInfo, "info");
                    r rVar = (r) aVar.f1809p;
                    if (rVar == null) {
                        i.g("srtClient");
                        throw null;
                    }
                    rVar.f6390c.getClass();
                    rVar.f6391d.b(new B1.d(AbstractC0752b.a(byteBuffer), AbstractC0752b.m(bufferInfo), B1.c.f113b));
                    return;
            }
        }
    }

    @Override // F1.c
    public final void n(boolean z4) {
        if (z4) {
            this.v = 0L;
        }
        this.f429l = z4;
        Log.i(this.f419a, "started");
    }

    @Override // F1.c
    public final void p() {
        Log.i(this.f419a, "stopped");
    }

    public final MediaCodecInfo q(String str) {
        ArrayList arrayListB;
        int i4 = this.f427j;
        if (i4 == 3) {
            arrayListB = H0.a.C("audio/mp4a-latm", false);
        } else if (i4 == 2) {
            arrayListB = H0.a.D("audio/mp4a-latm", false);
        } else if (i4 == 4) {
            arrayListB = H0.a.B(str);
        } else {
            ArrayList arrayList = new ArrayList();
            arrayList.addAll(H0.a.C(str, false));
            arrayList.addAll(H0.a.D(str, false));
            arrayListB = arrayList;
        }
        Log.i(this.f419a, arrayListB.size() + " encoders found");
        if (arrayListB.isEmpty()) {
            return null;
        }
        return (MediaCodecInfo) arrayListB.get(0);
    }

    public final boolean r(int i4, int i5, boolean z4) {
        if (this.f430m) {
            o(true);
        }
        this.f493s = i4;
        this.f494t = i5;
        this.f495u = z4;
        this.f426i = true;
        try {
            if (this.f432o.equals("audio/g711-alaw")) {
                char c5 = z4 ? (char) 2 : (char) 1;
                if (i5 != 8000 || c5 != 1) {
                    throw new IllegalArgumentException("G711 codec only support 8000 sampleRate and mono channel");
                }
                l();
                this.f425h = false;
                Log.i(this.f419a, "prepared");
                this.f430m = true;
                return true;
            }
            MediaCodecInfo mediaCodecInfoQ = q(this.f432o);
            if (mediaCodecInfoQ == null) {
                Log.e(this.f419a, "Valid encoder not found");
                return false;
            }
            Log.i(this.f419a, "Encoder selected " + mediaCodecInfoQ.getName());
            this.f423f = MediaCodec.createByCodecName(mediaCodecInfoQ.getName());
            MediaFormat mediaFormatCreateAudioFormat = MediaFormat.createAudioFormat(this.f432o, i5, z4 ? 2 : 1);
            mediaFormatCreateAudioFormat.setInteger("bitrate", i4);
            mediaFormatCreateAudioFormat.setInteger("max-input-size", 8192);
            mediaFormatCreateAudioFormat.setInteger("aac-profile", 2);
            l();
            this.f423f.configure(mediaFormatCreateAudioFormat, (Surface) null, (MediaCrypto) null, 1);
            this.f425h = false;
            Log.i(this.f419a, "prepared");
            this.f430m = true;
            return true;
        } catch (Exception e) {
            Log.e(this.f419a, "Create AudioEncoder failed.", e);
            o(true);
            return false;
        }
    }
}
