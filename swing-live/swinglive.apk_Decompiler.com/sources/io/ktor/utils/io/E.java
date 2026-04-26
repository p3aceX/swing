package io.ktor.utils.io;

import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
public class E extends IOException {
    public /* synthetic */ E(IndexOutOfBoundsException indexOutOfBoundsException) {
        super("CodedOutputStream was writing to a flat byte array and ran out of space.", indexOutOfBoundsException);
    }

    public E(Throwable th) {
        super(th != null ? th.getMessage() : null, th);
    }

    public E(String str, IndexOutOfBoundsException indexOutOfBoundsException) {
        super("CodedOutputStream was writing to a flat byte array and ran out of space.: ".concat(str), indexOutOfBoundsException);
    }
}
