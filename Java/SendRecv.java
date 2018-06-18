import mpi.*;

public class SendRecv {

	public static void main(String[] args) throws Exception {

		MPI.Init(args); int rank = MPI.COMM_WORLD.Rank(); int size = MPI.COMM_WORLD.Size() ;
		int unitSize=4, tag=100, master=0;

		if(rank == master) {
			int sendbuf[] = new int[unitSize*(size-1)];

		for(int i=1; i<size; i++)
			MPI.COMM_WORLD.Send(sendbuf, (i-1)*unitSize, unitSize, MPI.INT, i, tag);

		for(int i=1; i<size; i++)
			MPI.COMM_WORLD.Recv(sendbuf, (i-1)*unitSize, unitSize, MPI.INT, i, tag);

		for(int i=0; i<unitSize*(size-1) ; i++)
			System.out.print(sendbuf[i]+" ");
		} else {

		int recvbuf[] = new int[unitSize];
		MPI.COMM_WORLD.Recv(recvbuf, 0, unitSize, MPI.INT, master, tag);

		for(int i=0; i<unitSize; i++) recvbuf[i] = rank;

		MPI.COMM_WORLD.Send(recvbuf, 0, unitSize, MPI.INT, master, tag);
		}

		MPI.Finalize();
	}
}
