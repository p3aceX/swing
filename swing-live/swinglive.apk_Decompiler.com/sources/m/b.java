package M;

import android.util.Log;
import java.io.ByteArrayInputStream;
import java.io.DataInput;
import java.io.DataInputStream;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteOrder;

/* JADX INFO: loaded from: classes.dex */
public class b extends InputStream implements DataInput {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final DataInputStream f890a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f891b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public ByteOrder f892c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public byte[] f893d;
    public final int e;

    public b(byte[] bArr) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(bArr);
        ByteOrder byteOrder = ByteOrder.BIG_ENDIAN;
        this(byteArrayInputStream, 0);
        this.e = bArr.length;
    }

    public final void a(int i4) throws IOException {
        int i5 = 0;
        while (i5 < i4) {
            DataInputStream dataInputStream = this.f890a;
            int i6 = i4 - i5;
            int iSkip = (int) dataInputStream.skip(i6);
            if (iSkip <= 0) {
                if (this.f893d == null) {
                    this.f893d = new byte[8192];
                }
                iSkip = dataInputStream.read(this.f893d, 0, Math.min(8192, i6));
                if (iSkip == -1) {
                    throw new EOFException(B1.a.l("Reached EOF while skipping ", i4, " bytes."));
                }
            }
            i5 += iSkip;
        }
        this.f891b += i5;
    }

    @Override // java.io.InputStream
    public final int available() {
        return this.f890a.available();
    }

    @Override // java.io.InputStream
    public final void mark(int i4) {
        throw new UnsupportedOperationException("Mark is currently unsupported");
    }

    @Override // java.io.InputStream
    public final int read() {
        this.f891b++;
        return this.f890a.read();
    }

    @Override // java.io.DataInput
    public final boolean readBoolean() {
        this.f891b++;
        return this.f890a.readBoolean();
    }

    @Override // java.io.DataInput
    public final byte readByte() throws IOException {
        this.f891b++;
        int i4 = this.f890a.read();
        if (i4 >= 0) {
            return (byte) i4;
        }
        throw new EOFException();
    }

    @Override // java.io.DataInput
    public final char readChar() {
        this.f891b += 2;
        return this.f890a.readChar();
    }

    @Override // java.io.DataInput
    public final double readDouble() {
        return Double.longBitsToDouble(readLong());
    }

    @Override // java.io.DataInput
    public final float readFloat() {
        return Float.intBitsToFloat(readInt());
    }

    @Override // java.io.DataInput
    public final void readFully(byte[] bArr, int i4, int i5) throws IOException {
        this.f891b += i5;
        this.f890a.readFully(bArr, i4, i5);
    }

    @Override // java.io.DataInput
    public final int readInt() throws IOException {
        this.f891b += 4;
        DataInputStream dataInputStream = this.f890a;
        int i4 = dataInputStream.read();
        int i5 = dataInputStream.read();
        int i6 = dataInputStream.read();
        int i7 = dataInputStream.read();
        if ((i4 | i5 | i6 | i7) < 0) {
            throw new EOFException();
        }
        ByteOrder byteOrder = this.f892c;
        if (byteOrder == ByteOrder.LITTLE_ENDIAN) {
            return (i7 << 24) + (i6 << 16) + (i5 << 8) + i4;
        }
        if (byteOrder == ByteOrder.BIG_ENDIAN) {
            return (i4 << 24) + (i5 << 16) + (i6 << 8) + i7;
        }
        throw new IOException("Invalid byte order: " + this.f892c);
    }

    @Override // java.io.DataInput
    public final String readLine() {
        Log.d("ExifInterface", "Currently unsupported");
        return null;
    }

    @Override // java.io.DataInput
    public final long readLong() throws IOException {
        long j4;
        long j5;
        this.f891b += 8;
        DataInputStream dataInputStream = this.f890a;
        int i4 = dataInputStream.read();
        int i5 = dataInputStream.read();
        int i6 = dataInputStream.read();
        int i7 = dataInputStream.read();
        int i8 = dataInputStream.read();
        int i9 = dataInputStream.read();
        int i10 = dataInputStream.read();
        int i11 = dataInputStream.read();
        if ((i4 | i5 | i6 | i7 | i8 | i9 | i10 | i11) < 0) {
            throw new EOFException();
        }
        ByteOrder byteOrder = this.f892c;
        if (byteOrder == ByteOrder.LITTLE_ENDIAN) {
            j4 = (((long) i11) << 56) + (((long) i10) << 48) + (((long) i9) << 40) + (((long) i8) << 32) + (((long) i7) << 24) + (((long) i6) << 16) + (((long) i5) << 8);
            j5 = i4;
        } else {
            if (byteOrder != ByteOrder.BIG_ENDIAN) {
                throw new IOException("Invalid byte order: " + this.f892c);
            }
            j4 = (((long) i4) << 56) + (((long) i5) << 48) + (((long) i6) << 40) + (((long) i7) << 32) + (((long) i8) << 24) + (((long) i9) << 16) + (((long) i10) << 8);
            j5 = i11;
        }
        return j4 + j5;
    }

    @Override // java.io.DataInput
    public final short readShort() throws IOException {
        this.f891b += 2;
        DataInputStream dataInputStream = this.f890a;
        int i4 = dataInputStream.read();
        int i5 = dataInputStream.read();
        if ((i4 | i5) < 0) {
            throw new EOFException();
        }
        ByteOrder byteOrder = this.f892c;
        if (byteOrder == ByteOrder.LITTLE_ENDIAN) {
            return (short) ((i5 << 8) + i4);
        }
        if (byteOrder == ByteOrder.BIG_ENDIAN) {
            return (short) ((i4 << 8) + i5);
        }
        throw new IOException("Invalid byte order: " + this.f892c);
    }

    @Override // java.io.DataInput
    public final String readUTF() {
        this.f891b += 2;
        return this.f890a.readUTF();
    }

    @Override // java.io.DataInput
    public final int readUnsignedByte() {
        this.f891b++;
        return this.f890a.readUnsignedByte();
    }

    @Override // java.io.DataInput
    public final int readUnsignedShort() throws IOException {
        this.f891b += 2;
        DataInputStream dataInputStream = this.f890a;
        int i4 = dataInputStream.read();
        int i5 = dataInputStream.read();
        if ((i4 | i5) < 0) {
            throw new EOFException();
        }
        ByteOrder byteOrder = this.f892c;
        if (byteOrder == ByteOrder.LITTLE_ENDIAN) {
            return (i5 << 8) + i4;
        }
        if (byteOrder == ByteOrder.BIG_ENDIAN) {
            return (i4 << 8) + i5;
        }
        throw new IOException("Invalid byte order: " + this.f892c);
    }

    @Override // java.io.InputStream
    public final void reset() {
        throw new UnsupportedOperationException("Reset is currently unsupported");
    }

    @Override // java.io.DataInput
    public final int skipBytes(int i4) {
        throw new UnsupportedOperationException("skipBytes is currently unsupported");
    }

    /* JADX WARN: 'this' call moved to the top of the method (can break code semantics) */
    public b(InputStream inputStream) {
        this(inputStream, 0);
        ByteOrder byteOrder = ByteOrder.BIG_ENDIAN;
    }

    @Override // java.io.InputStream
    public final int read(byte[] bArr, int i4, int i5) throws IOException {
        int i6 = this.f890a.read(bArr, i4, i5);
        this.f891b += i6;
        return i6;
    }

    @Override // java.io.DataInput
    public final void readFully(byte[] bArr) throws IOException {
        this.f891b += bArr.length;
        this.f890a.readFully(bArr);
    }

    public b(InputStream inputStream, int i4) {
        ByteOrder byteOrder = ByteOrder.BIG_ENDIAN;
        DataInputStream dataInputStream = new DataInputStream(inputStream);
        this.f890a = dataInputStream;
        dataInputStream.mark(0);
        this.f891b = 0;
        this.f892c = byteOrder;
        this.e = inputStream instanceof b ? ((b) inputStream).e : -1;
    }
}
