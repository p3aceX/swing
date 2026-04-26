package io.ktor.network.sockets;

import java.io.IOException;
import java.net.SocketOption;
import java.net.StandardSocketOptions;
import java.nio.channels.DatagramChannel;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.nio.channels.spi.AbstractSelectableChannel;

/* JADX INFO: loaded from: classes.dex */
public abstract class v {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final boolean f4938a;

    static {
        boolean z4;
        try {
            Class.forName("java.net.StandardSocketOptions");
            z4 = true;
        } catch (ClassNotFoundException unused) {
            z4 = false;
        }
        f4938a = z4;
    }

    public static final void a(AbstractSelectableChannel abstractSelectableChannel, E e) throws IOException {
        J3.i.e(e, "options");
        boolean z4 = abstractSelectableChannel instanceof SocketChannel;
        boolean z5 = f4938a;
        if (z4) {
            int i4 = e.f4839c;
            Integer numValueOf = Integer.valueOf(i4);
            if (i4 <= 0) {
                numValueOf = null;
            }
            if (numValueOf != null) {
                int iIntValue = numValueOf.intValue();
                if (z5) {
                    ((SocketChannel) abstractSelectableChannel).setOption((SocketOption<Integer>) StandardSocketOptions.SO_RCVBUF, Integer.valueOf(iIntValue));
                } else {
                    ((SocketChannel) abstractSelectableChannel).socket().setReceiveBufferSize(iIntValue);
                }
            }
            if (e instanceof F) {
                F f4 = (F) e;
                int i5 = f4.e;
                Integer numValueOf2 = Integer.valueOf(i5);
                if (i5 < 0) {
                    numValueOf2 = null;
                }
                if (numValueOf2 != null) {
                    int iIntValue2 = numValueOf2.intValue();
                    if (z5) {
                        ((SocketChannel) abstractSelectableChannel).setOption((SocketOption<Integer>) StandardSocketOptions.SO_LINGER, Integer.valueOf(iIntValue2));
                    } else {
                        ((SocketChannel) abstractSelectableChannel).socket().setSoLinger(true, iIntValue2);
                    }
                }
                if (z5) {
                    ((SocketChannel) abstractSelectableChannel).setOption((SocketOption<Boolean>) StandardSocketOptions.TCP_NODELAY, Boolean.valueOf(f4.f4840d));
                } else {
                    ((SocketChannel) abstractSelectableChannel).socket().setTcpNoDelay(f4.f4840d);
                }
            }
        }
        boolean z6 = abstractSelectableChannel instanceof ServerSocketChannel;
        if (abstractSelectableChannel instanceof DatagramChannel) {
            if (e instanceof G) {
                if (z5) {
                    ((DatagramChannel) abstractSelectableChannel).setOption((SocketOption<Boolean>) StandardSocketOptions.SO_BROADCAST, Boolean.valueOf(((G) e).f4842d));
                } else {
                    ((DatagramChannel) abstractSelectableChannel).socket().setBroadcast(((G) e).f4842d);
                }
            }
            int i6 = e.f4839c;
            Integer numValueOf3 = i6 > 0 ? Integer.valueOf(i6) : null;
            if (numValueOf3 != null) {
                int iIntValue3 = numValueOf3.intValue();
                if (z5) {
                    ((DatagramChannel) abstractSelectableChannel).setOption((SocketOption<Integer>) StandardSocketOptions.SO_RCVBUF, Integer.valueOf(iIntValue3));
                } else {
                    ((DatagramChannel) abstractSelectableChannel).socket().setReceiveBufferSize(iIntValue3);
                }
            }
        }
    }
}
