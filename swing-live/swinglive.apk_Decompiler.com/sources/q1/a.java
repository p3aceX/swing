package Q1;

import android.media.MediaCodec;
import android.media.MediaFormat;
import java.nio.ByteBuffer;

/* JADX INFO: loaded from: classes.dex */
public interface a {
    void l(ByteBuffer byteBuffer, MediaCodec.BufferInfo bufferInfo);

    void o(ByteBuffer byteBuffer, ByteBuffer byteBuffer2, ByteBuffer byteBuffer3);

    void r(MediaFormat mediaFormat);
}
