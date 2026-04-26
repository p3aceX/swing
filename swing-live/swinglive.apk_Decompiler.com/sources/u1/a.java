package U1;

import android.media.MediaCodec;
import android.media.MediaFormat;
import android.util.Log;
import java.nio.ByteBuffer;
import y1.EnumC0758h;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f2089a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public EnumC0758h f2090b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f2091c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f2092d;
    public volatile long e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public int f2093f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public MediaFormat f2094g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public MediaFormat f2095h;

    public final boolean a(ByteBuffer byteBuffer) {
        byte[] bArr = new byte[5];
        if (byteBuffer.remaining() < 5) {
            return false;
        }
        byteBuffer.duplicate().get(bArr, 0, 5);
        EnumC0758h enumC0758h = EnumC0758h.f6858c;
        EnumC0758h enumC0758h2 = this.f2090b;
        if (enumC0758h2 == enumC0758h) {
            return false;
        }
        if (enumC0758h2 == EnumC0758h.f6856a && (bArr[4] & 31) == 5) {
            return true;
        }
        return (enumC0758h2 == EnumC0758h.f6857b && ((bArr[4] >> 1) & 63) == 19) || ((bArr[4] >> 1) & 63) == 20;
    }

    public final boolean b() {
        int i4 = this.f2089a;
        return i4 == 1 || i4 == 3 || i4 == 5 || i4 == 4;
    }

    public final void c(ByteBuffer byteBuffer, MediaCodec.BufferInfo bufferInfo) {
        int i4 = this.f2089a;
        int i5 = this.f2093f;
        if (i4 != 1 || this.f2094g == null || (this.f2095h == null && i5 != 2)) {
            if (i4 == 5 && (bufferInfo.flags == 1 || a(byteBuffer))) {
                this.f2089a = 3;
            }
        } else if (bufferInfo.flags == 1 || a(byteBuffer)) {
            throw null;
        }
        if (this.f2089a != 3 || i5 == 3) {
            return;
        }
        d(this.f2091c, bufferInfo);
    }

    public final void d(int i4, MediaCodec.BufferInfo bufferInfo) {
        if (i4 == -1) {
            return;
        }
        String str = i4 == this.f2092d ? "Audio" : "Video";
        try {
            MediaCodec.BufferInfo bufferInfo2 = new MediaCodec.BufferInfo();
            if (this.e <= 0) {
                this.e = bufferInfo.presentationTimeUs;
            }
            bufferInfo2.set(bufferInfo.offset, bufferInfo.size, Math.max(0L, bufferInfo.presentationTimeUs - this.e), bufferInfo.flags);
            Log.i("RecordController", str + ", ts: " + bufferInfo2.presentationTimeUs + ", flag: " + bufferInfo2.flags);
            throw null;
        } catch (Exception unused) {
        }
    }
}
