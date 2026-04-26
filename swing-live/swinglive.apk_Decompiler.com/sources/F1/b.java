package F1;

import android.media.MediaCodec;
import android.media.MediaFormat;
import android.util.Log;
import java.nio.ByteBuffer;

/* JADX INFO: loaded from: classes.dex */
public final class b extends MediaCodec.Callback {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ c f418a;

    public b(c cVar) {
        this.f418a = cVar;
    }

    @Override // android.media.MediaCodec.Callback
    public final void onError(MediaCodec mediaCodec, MediaCodec.CodecException codecException) {
        c cVar = this.f418a;
        Log.e(cVar.f419a, "Error", codecException);
        cVar.getClass();
    }

    @Override // android.media.MediaCodec.Callback
    public final void onInputBufferAvailable(MediaCodec mediaCodec, int i4) {
        c cVar = this.f418a;
        try {
            cVar.h(mediaCodec, i4);
        } catch (IllegalStateException e) {
            Log.i(cVar.f419a, "Encoding error", e);
            cVar.i(e);
        }
    }

    @Override // android.media.MediaCodec.Callback
    public final void onOutputBufferAvailable(MediaCodec mediaCodec, int i4, MediaCodec.BufferInfo bufferInfo) {
        c cVar = this.f418a;
        try {
            cVar.getClass();
            ByteBuffer outputBuffer = mediaCodec.getOutputBuffer(i4);
            cVar.b(outputBuffer, bufferInfo);
            cVar.k(outputBuffer, bufferInfo);
            mediaCodec.releaseOutputBuffer(i4, false);
        } catch (IllegalStateException e) {
            Log.i(cVar.f419a, "Encoding error", e);
            cVar.i(e);
        }
    }

    @Override // android.media.MediaCodec.Callback
    public final void onOutputFormatChanged(MediaCodec mediaCodec, MediaFormat mediaFormat) {
        this.f418a.d(mediaFormat);
    }
}
